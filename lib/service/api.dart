import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xml2json/xml2json.dart';
import 'package:uuid/uuid.dart';

import 'package:linkeat/models/store.dart';
import 'package:linkeat/models/order.dart';
import 'package:linkeat/models/cms.dart';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/config.dart';

Future<List<StoreSummary>> fetchPopularStores(BuildContext context) async {
  final dynamic response = await Services.asyncRequest(
      'GET', '/store/campaign/${Constants.HOME_CAMPAIGN_ID}', context);
  var data = json.decode(response.toString());
  var stores = data["stores"] as List;
  if (stores.length == 0) {
    throw Exception('Failed to load stores');
  }
  return stores
      .map<StoreSummary>((json) => StoreSummary.fromJson(json))
      .toList();
}

Future<List<Order>?> fetchOrders(
    {BuildContext? context, int? pageIdx, int? pageSize}) async {
  final dynamic response = await Services.asyncRequest('GET',
      '/store/my/orders?pageIdx=${pageIdx}&pageSize=${pageSize}', context);
  var data = json.decode(response.toString());

//  return data['records'].map((item) => Order.fromJson(item)).toList();

  return data['records'].map<Order>((json) => Order.fromJson(json)).toList();
}

Future<Order> fetchOrderById(BuildContext context, String? orderId) async {
  final dynamic response =
      await Services.asyncRequest('GET', '/store/my/order/${orderId}', context);
  var data = json.decode(response.toString());

  return Order.fromJson(data);
}

Future<List<Album>> fetchAlbums(BuildContext context) async {
  final dynamic response = await Services.asyncRequest('GET',
      '/cms/media/bundle?source=${Constants.HOME_MEDIA_BUNDLE}', context);
  var data = json.decode(response.toString());
  var bundle = data["bundle"] as List;
  if (bundle.length == 0) {
    throw Exception('Failed to load album');
  }
  var items = bundle[0]['items'] as List;
  return items.map<Album>((json) => Album.fromJson(json)).toList();
}

Future<void> initPODTransacton(
    {required BuildContext context,
    String? orderId,
    String? storeId,
    int? amount}) async {
  await Services.asyncRequest(
      'POST', '/store/v2/${storeId}/transaction', context,
      payload: {
        'storeId': storeId,
        'orderId': orderId,
        'paymentMethod': 'PAYONDELIVERY',
        'currency': 'AUD',
        'amount': amount,
        'app': 'LINKEAT', // FIXME
        'device': 'WXAPP', // FIXME
      });
  Navigator.pushNamed(
    context,
    '/orderComplete',
  );
}

Future<dynamic> initSUPAYTransacton(
    {BuildContext? context,
    String? orderId,
    String? storeId,
    int? amount,
    String? gateway}) async {
  final dynamic response = await Services.asyncRequest(
      'POST', '/store/v2/${storeId}/transaction', context,
      payload: {
        'storeId': storeId,
        'orderId': orderId,
        'paymentMethod': 'WINDCAVEH5',
        'currency': 'AUD',
        'amount': amount,
        'app': 'LINKEAT', // FIXME
        'device': 'WXAPP', // FIXME
      });
  var data = json.decode(response.toString());
  return data;
}



Future<void> initBankTransferTransacton(
    {BuildContext? context,
    String? orderId,
    String? storeId,
    int? amount}) async {
  final ImagePicker _picker = ImagePicker();
  final File? image = await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 600,
    maxHeight: 480,
  ) as File?;
  if (image != null) {
    final Uuid uuid = Uuid();
    final String imgType = image.path.split('.')[1];
    final String fileName =
        image.path.split('/')[image.path.split('/').length - 1];
    final dynamic response = await Services.asyncRequest(
        'GET', '/cms/media/uploadForm', context, params: <String, String>{
      'key': '${uuid.v4()}$fileName',
      'mimeType': 'image/$imgType'
    });
    if (response != null) {
      final UploadFormResponse uploadForm = UploadFormResponse.fromJson(
          json.decode(response.toString())['uploadForm']);
//      _uploadImage(uploadForm, image);
      final Dio dio = Dio();
      final dynamic imgUrlPayload = await dio.post<dynamic>(uploadForm.postUrl!,
          data: await uploadForm.toFormData(image));
      final Xml2Json xml2json = Xml2Json();
      xml2json.parse(imgUrlPayload.toString());
      final String? imageUrl =
          json.decode(xml2json.toGData())['PostResponse']['Location']['\$t'];

      await Services.asyncRequest(
          'POST', '/store/v2/${storeId}/transaction', context,
          payload: {
            'storeId': storeId,
            'orderId': orderId,
            'paymentMethod': 'BANKTRANSFER',
            'currency': 'AUD',
            'amount': amount,
            'app': 'LINKEAT', // FIXME
            'device': 'WXAPP', // FIXME
            'bankTransferScreenshotUrl': imageUrl,
          });
      Navigator.pushNamed(
        context!,
        '/orderComplete',
      );
    }
  }
}

//Future<void> _getSignedUrl(
//    File image, BuildContext context) async {
//
//}
//
//Future<void> _uploadImage(
//    UploadFormResponse uploadForm, File image) async {
//
//
//}

class UploadFormResponse {
  UploadFormResponse.fromJson(Map<String, dynamic> json) {
    awsAccessKeyId = json['awsAccessKeyId'];
    contentType = json['contentType'];
    key = json['key'];
    policy = json['policy'];
    postUrl = json['postUrl'];
    signature = json['signature'];
  }

  @override
  String toString() {
    return 'UploadFormResponse{postUrl: $postUrl, awsAccessKeyId: $awsAccessKeyId}';
  }

  Future<FormData> toFormData(File file) async {
    final String fileName =
        file.path.split('/')[file.path.split('/').length - 1];
    print(fileName);
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'AWSAccessKeyId': awsAccessKeyId,
      'Content-Type': contentType,
      'key': key,
      'policy': policy,
      'acl': 'public-read',
      'signature': signature,
      'success_action_status': '201',
      'file': await MultipartFile.fromFile(file.path, filename: fileName)
    });
    return formData;
  }

  String? awsAccessKeyId;
  String? contentType;
  String? key;
  String? policy;
  String? postUrl;
  String? signature;
}
