import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';


const bucketId = "caesar-flutter-storage";
const accessKey = "ZHDREPK6EN0WNIB5JDFI";
const secretKey = "Ey7umByPHhhwEyeiuwnaS0Rp75mWSkNfkzeEqNQD";
const host = "is3.cloudhost.id";
const region = "us-east-1";



final s3client = AwsS3Client(
  region: region,
  host: host,
  bucketId: bucketId,
  accessKey: accessKey,
  secretKey: secretKey,
);

Future<http.MultipartFile> createMultipartFileFromStream(File file, String fieldName, String filename) async {
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
List<int> getSigningKey(String secretKey, String dateStamp, String regionName, String serviceName) {
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
  final key = 'gambar/$filename'; // Where you want to store the file.// **Keep this secure!**// For Minio, this can usually be a dummy value.

  print("ngaplod masbre nyang $filename");

  // siji
  final now = DateTime.now().toUtc();
  final dateStamp = getDateStamp(now);         // Format: YYYYMMDD
  final amzDate = getAmzDate(now);               // Format: YYYYMMDD'T'HHMMSS'Z'

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

  var multipartFile = await createMultipartFileFromStream(file, 'file', filename);
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