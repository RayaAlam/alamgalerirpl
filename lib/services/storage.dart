import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:flutter_uilogin/services/server_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

final s3client = AwsS3Client(
  region: region,
  host: host,
  bucketId: bucketId,
  accessKey: accessKey,
  secretKey: secretKey,
);

Future<http.MultipartFile> createMultipartFileFromStream(
    File file, String fieldName, String filename) async {
  final stream = file.openRead();
  final length = await file.length();
  return http.MultipartFile(
    fieldName,
    stream,
    length,
    filename: filename,
    // You can also set the content type if needed:
    // contentType: MediaType('image', 'jpeg'),
  );
}

/// Computes an HMAC-SHA256 hash.
List<int> _hmacSha256(List<int> key, List<int> message) {
  final hmac = Hmac(sha256, key);
  return hmac.convert(message).bytes;
}

/// Converts a list of bytes to a hex string.
String _toHex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
}

/// Derives the signing key for AWS Signature Version 4.
/// Normally, this should be done on your backend.
List<int> getSigningKey(
    String secretKey, String dateStamp, String regionName, String serviceName) {
  final kSecret = utf8.encode('AWS4' + secretKey);
  final kDate = _hmacSha256(kSecret, utf8.encode(dateStamp));
  final kRegion = _hmacSha256(kDate, utf8.encode(regionName));
  final kService = _hmacSha256(kRegion, utf8.encode(serviceName));
  final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
  return kSigning;
}

/// Formats a DateTime as a date stamp (YYYYMMDD).
String getDateStamp(DateTime dateTime) {
  final year = dateTime.year.toString();
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year$month$day';
}

/// Formats a DateTime as an amz date (YYYYMMDD'T'HHMMSS'Z').
String getAmzDate(DateTime dateTime) {
  final year = dateTime.year.toString();
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final second = dateTime.second.toString().padLeft(2, '0');
  return '$year$month${day}T$hour$minute${second}Z';
}

String generateRandomString(int length) {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

/// Uploads a file to a Minio (or S3-compatible) endpoint using a POST request.
///
/// This function builds the policy document, Base64-encodes it,
/// computes the signature, and then attaches the file as part of a multipart form.
/// Adjust the variables (bucket, keys, dates, etc.) to fit your configuration.
Future<String> uploadFile(File file) async {
  final filename = generateRandomString(16);
  // Configuration variables.
  final bucket = bucketId;
  final key =
      'gambar/$filename'; // Where you want to store the file.// **Keep this secure!**// For Minio, this can usually be a dummy value.

  print("upload to $filename");

  // siji
  final now = DateTime.now().toUtc();
  final dateStamp = getDateStamp(now); // Format: YYYYMMDD
  final amzDate = getAmzDate(now); // Format: YYYYMMDD'T'HHMMSS'Z'

  // loro
  final expiration = now.add(Duration(hours: 1)).toIso8601String();

  // Create a policy document. Adjust expiration and conditions as needed.
  final policy = {
    'expiration': expiration,
    'conditions': [
      {'bucket': bucket},
      {"acl": 'public-read'},
      // Ensures the key starts with "uploads/"
      ['starts-with', '\$key', 'gambar/'],
      // You can add more conditions here, for example to restrict file size:
      // ['content-length-range', 0, 10485760],
      {'x-amz-algorithm': 'AWS4-HMAC-SHA256'},
      {'x-amz-credential': '$accessKey/$dateStamp/$region/s3/aws4_request'},
      {'x-amz-date': amzDate},
    ],
  };

  // Convert the policy JSON to a string and then Base64-encode it.
  final policyJson = json.encode(policy);
  final policyBase64 = base64.encode(utf8.encode(policyJson));
  print('Policy JSON: $policyJson');
  print('Policy Base64: $policyBase64');

  // Compute the signing key and then the signature.
  final signingKey = getSigningKey(secretKey, dateStamp, region, 's3');
  final signatureBytes = _hmacSha256(signingKey, utf8.encode(policyBase64));
  final signature = _toHex(signatureBytes);
  print('Computed Signature: $signature');

  // Prepare the form fields required for the POST request.
  final fields = {
    'key': key,
    'policy': policyBase64,
    'x-amz-algorithm': 'AWS4-HMAC-SHA256',
    'x-amz-credential': '$accessKey/$dateStamp/$region/s3/aws4_request',
    'x-amz-date': amzDate,
    'x-amz-signature': signature,
    'acl': 'public-read',
  };

  // Set your endpoint URL.
  // For a local Minio server, you might have something like:
  final uri = Uri.parse('https://$host/$bucket');
  print('Endpoint URI: $uri');

  // Create a multipart POST request.
  var request = http.MultipartRequest('POST', uri);
  request.fields.addAll(fields);

  var multipartFile =
      await createMultipartFileFromStream(file, 'file', filename);
  request.files.add(multipartFile);

  // Send the request.
  var response = await request.send();

  // Check the response.
  if (response.statusCode == 204 || response.statusCode == 201) {
    print('Upload successful!');
  } else {
    print('Upload failed with status code: ${response.statusCode}');
    var responseBody = await response.stream.bytesToString();
    print('Response body: $responseBody');
  }

  return filename;
}

/// Generate a presigned URL for S3 GET Object using AWS Signature Version 4.
///
/// [accessKey] and [secretKey] are your AWS credentials.
/// [region] is your S3 bucket region (e.g., 'us-east-1').
/// [bucket] is your S3 bucket name.
/// [key] is the object key in S3 (do not include a leading slash).
/// [expiration] is the time in seconds until the URL expires.
String generatePresignedUrl({
  required String key,
  int expiration = 3600,
}) {
  // Configuration variables.
  final bucket = bucketId;
  final service = 's3';
  final algorithm = 'AWS4-HMAC-SHA256';

  // Get the current UTC time
  final now = DateTime.now().toUtc();
  final amzDate = getAmzDate(now); // e.g. 20250211T123456Z
  final dateStamp = getDateStamp(now); // e.g. 20250211

  // Credential scope (used in both query params and string to sign)
  final credentialScope = '$dateStamp/$region/$service/aws4_request';

  // Query parameters required for a presigned URL
  final queryParams = {
    'X-Amz-Algorithm': algorithm,
    'X-Amz-Credential': '$accessKey/$dateStamp/$region/s3/aws4_request',
    'X-Amz-Date': amzDate,
    'X-Amz-Expires': expiration.toString(),
    'X-Amz-SignedHeaders': 'host',
  };

  // Construct the canonical query string from sorted query parameters.
  final sortedKeys = queryParams.keys.toList()..sort();
  final canonicalQuery = sortedKeys
      .map((key) =>
          '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(queryParams[key]!)}')
      .join('&');

  // Create canonical headers. For S3, we only need the host header.
  final canonicalHeaders = 'host:$host\n';
  final signedHeaders = 'host';
  final payloadHash = "UNSIGNED-PAYLOAD";

  // Build the canonical request
  // The canonical URI must start with a slash.
  final canonicalRequest = [
    'GET',
    '/$bucket/$key',
    canonicalQuery,
    canonicalHeaders,
    signedHeaders,
    payloadHash,
  ].join('\n');

  // Create the string to sign.
  final hashedCanonicalRequest =
      sha256.convert(utf8.encode(canonicalRequest)).toString();
  final stringToSign = [
    algorithm,
    amzDate,
    credentialScope,
    hashedCanonicalRequest,
  ].join('\n');

  // Derive the signing key
  final signingKey = getSigningKey(secretKey, dateStamp, region, 's3');

  // Calculate the signature as hex.
  final signature = _toHex(_hmacSha256(signingKey, utf8.encode(stringToSign)));

  // Build the final presigned URL
  final presignedUri = Uri.https(
    host,
    '/$bucket/$key',
    {
      ...queryParams,
      'X-Amz-Signature': signature,
    },
  );

  print("dapet presigned url from $key");
  print(presignedUri.toString());

  return presignedUri.toString();
}
