import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../../../components/cards/app_update_card.dart';
import '../../../../logic/network/network_repo.dart';
import '../../../../logic/model/check_update/check_update.dart';
import '../../../../logic/model/check_update/datum.dart';
import '../../../../logic/state/loading_state.dart';
import '../../../../pages/home/app/controller.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/token_util.dart';

class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({super.key});

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  late List<String> _packageNames;
  late List<String> _versionNames;
  late List<String> _versionCodes;
  late String _pkgs;

  final AppListController _appListController = Get.put(AppListController());
  LoadingState? _loadingState = LoadingState.loading();
  int? _length;

  @override
  void initState() {
    super.initState();

    _packageNames =
        _appListController.state?.map((info) => info.packageName).toList() ??
            [];
    _versionNames =
        _appListController.state?.map((info) => info.versionName).toList() ??
            [];
    _versionCodes =
        _appListController.state?.map((info) => info.versionCode).toList() ??
            [];
    List<String> values =
        _versionCodes.map((version) => '0,$version,0').toList();
    Map<String, String> pkgsMap = Map.fromIterables(_packageNames, values);
    _pkgs = TokenUtils.getBase64(jsonEncode(pkgsMap));
    _getData();
  }

  @override
  void dispose() {
    _loadingState = null;
    super.dispose();
  }

  Future<void> _getData() async {
    try {
      Response response = await NetworkRepo.getAppsUpdate(_pkgs);
      if (response.statusCode == HttpStatus.ok) {
        CheckUpdate responseData = CheckUpdate.fromJson(response.data);
        if (!responseData.message.isNullOrEmpty) {
          setState(() =>
              _loadingState = LoadingState.error(response.data['message']));
        } else {
          if (!responseData.data.isNullOrEmpty) {
            setState(() {
              _length = responseData.data!.length;
              _loadingState = LoadingState.success(responseData.data);
            });
          } else {
            setState(() => _loadingState = LoadingState.empty());
          }
        }
      } else {
        setState(() => _loadingState =
            LoadingState.error('statusCode: ${response.statusCode}'));
      }
    } catch (e) {
      setState(() => _loadingState = LoadingState.error(e.toString()));
    }
  }

  Widget _buildBody() {
    switch (_loadingState) {
      case Empty():
        return GestureDetector(
          onTap: () {
            setState(() => _loadingState = LoadingState.loading());
            _getData();
          },
          child: Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: () {
            setState(() => _loadingState = LoadingState.loading());
            _getData();
          },
          child: Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text((_loadingState as Error).errMsg),
          ),
        );
      case Success():
        List<Datum> dataList =
            (_loadingState as Success).response as List<Datum>;
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom),
          itemCount: dataList.length,
          itemBuilder: (_, index) {
            int pos = _packageNames.indexOf(dataList[index].packageName ?? '');
            return AppUpdateCard(
              data: dataList[index],
              versionName: pos < 0 ? null : _versionNames[pos],
              versionCode: pos < 0 ? null : _versionCodes[pos],
            );
          },
          separatorBuilder: (_, index) => const SizedBox(height: 10),
        );
    }
    return Container(
      height: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10.0),
      child: const CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update${_length != null ? ': $_length' : ''}'),
        bottom: const PreferredSize(
          preferredSize: Size.zero,
          child: Divider(height: 1),
        ),
      ),
      body: _loadingState is Success
          ? RefreshIndicator(
              onRefresh: () async {
                await _getData();
              },
              child: _buildBody(),
            )
          : Center(child: _buildBody()),
    );
  }
}
