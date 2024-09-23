import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:linkeat/models/routeArguments.dart';
import 'package:dio/dio.dart';

import 'package:linkeat/config.dart';
import 'package:linkeat/service/request_failure.dart';
import 'package:linkeat/utils/SharedPreferences_util.dart';
import 'package:linkeat/utils/datetime_util.dart';

class Services {
  static const String defaultCode = '-1';
  final int requestMinThreshold = 500;
  static final Dio dio = Dio();

//  static final rest = Dio(_options);

  static dynamic asyncRequest(String method, String url, BuildContext? context,
      {dynamic payload, Map<String, dynamic>? params, String? otp}) async {
    try {
      final String? accessToken =
          await SharedPreferencesUtil.getStringItem(SharedType.TOKEN);

      dio.interceptors.add(InterceptorsWrapper(onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) {
        if (accessToken != null) {
          options.headers['Authorization'] = accessToken;
//          options.headers['device'] = 'LINKBOSS';
        }
        if (otp != null) {
          options.headers['otp'] = otp;
        }
        return handler.next(options);
      }, onError: (DioError e, ErrorInterceptorHandler handler) {
        print(e.message);
        return handler.next(e);
      }));
      if (!url.startsWith('http')) {
        url = '${Constants.API_URI}$url';
      }

      Response? response;
      switch (method) {
        case 'POST':
          response = await dio.post<dynamic>(url,
              queryParameters: params, data: payload);

          break;
        case 'GET':
          response = await dio.get<dynamic>(
            url,
            queryParameters: params,
          );

          break;
        case 'PUT':
          response = await dio.put<dynamic>(url,
              queryParameters: params, data: payload);

          break;
        case 'DELETE':
          response = await dio.delete<dynamic>(
            url,
            queryParameters: params,
          );

          break;
      }

      print(response);
      return response == null ? 'success' : response;
    } on DioError catch (error) {

      String? message = '';
      String code = '-1';

      final Map<String, dynamic> errorData =
          json.decode(error.response.toString());
      try {
        message = errorData['reason'] != null
            ? errorData['reason']
            : errorData['error'];
      } on FormatException catch (e) {
        print(e.toString());
        message = 'Network Error';
      }
      code = error.response!.statusCode.toString();

      // can be used for Sentry
      final RequestFailureInfo model = RequestFailureInfo(
          errorCode: code,
          errorMessage: message,
          dateTime: DateTimeUtil.dateTimeNowIso());
      if (model.errorCode == '403') {
        // in this case, do not clear username and password
        SharedPreferencesUtil.removeByLabel('accessToken');
        Navigator.pushNamed(
          context!,
          '/login',
          arguments: LoginArguments(
            true,
          ),
        );
      }
      final String errMsg = '${model.errorCode}: ${model.errorMessage}';

      showDialog<String>(
          context: context!,
          builder: (BuildContext buildContext) {
            return AlertDialog(
              title: Text(errMsg),
            );
          });
    }
  }
}
