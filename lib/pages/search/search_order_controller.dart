import 'package:get/get.dart';

import '../../pages/search/search_result_page.dart'
    show SearchType, SearchSortType;

class SearchOrderController extends GetxController {
  Rx<SearchType> searchType = SearchType.ALL.obs;
  Rx<SearchSortType> searchSortType = SearchSortType.DATELINE.obs;

  void setSearchType(SearchType searchType) {
    this.searchType.value = searchType;
  }

  void setSearchSortType(SearchSortType searchSortType) {
    this.searchSortType.value = searchSortType;
  }
}
