import 'package:get/get.dart';

class ReturnTopController extends GetxController {
  RxInt index = 999.obs;

  void setIndex(int index) {
    this.index.value = index;
  }
}
