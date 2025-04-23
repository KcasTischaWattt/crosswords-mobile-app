class ArticleSearchParams {
  final String _searchQuery;
  final String _dateFrom;
  final String _dateTo;
  final List<String> _selectedSources;
  final List<String> _selectedTags;
  final bool _searchInText;
  final String _searchOption;

  String get searchQuery => _searchQuery;
  String get dateFrom => _dateFrom;
  String get dateTo => _dateTo;
  List<String> get selectedSources => _selectedSources;
  List<String> get selectedTags => _selectedTags;
  bool get searchInText => _searchInText;
  String get searchOption => _searchOption;

  ArticleSearchParams({
    required String searchQuery,
    required String dateFrom,
    required String dateTo,
    required List<String> selectedSources,
    required List<String> selectedTags,
    required bool searchInText,
    required String searchOption,
  })  : _searchQuery = searchQuery,
        _dateFrom = dateFrom,
        _dateTo = dateTo,
        _selectedSources = selectedSources,
        _selectedTags = selectedTags,
        _searchInText = searchInText,
        _searchOption = searchOption;

  factory ArticleSearchParams.fromJson(Map<String, dynamic> json) {
    return ArticleSearchParams(
      searchQuery: json['search_query'],
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      selectedSources: List<String>.from(json['selected_sources']),
      selectedTags: List<String>.from(json['selected_tags']),
      searchInText: json['search_in_text'],
      searchOption: json['search_option'],
    );
  }

  ArticleSearchParams copyWith({
    String? searchQuery,
    String? dateFrom,
    String? dateTo,
    List<String>? selectedSources,
    List<String>? selectedTags,
    bool? searchInText,
    String? searchOption,
  }) {
    return ArticleSearchParams(
      searchQuery: searchQuery ?? this.searchQuery,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      selectedSources: selectedSources ?? List.from(this.selectedSources),
      selectedTags: selectedTags ?? List.from(this.selectedTags),
      searchInText: searchInText ?? this.searchInText,
      searchOption: searchOption ?? this.searchOption,
    );
  }

  ArticleSearchParams resetFilters() {
    return ArticleSearchParams(
      searchQuery: '',
      dateFrom: '',
      dateTo: '',
      selectedSources: [],
      selectedTags: [],
      searchInText: false,
      searchOption: searchOption,
    );
  }

  Map<String, dynamic> toApiJson(int page, int pageSize, bool isFavorite) {
    return {
      "language": null,
      "sources": selectedSources.isEmpty ? null : selectedSources,
      "tags": selectedTags.isEmpty ? null : selectedTags,
      "folders": isFavorite ? ["favorite"] : null,
      "search_body": searchQuery.isEmpty ? null : searchQuery,
      "search_mode": searchOption,
      "date_from": dateFrom.isEmpty ? null : dateFrom,
      "date_to": dateTo.isEmpty ? null : dateTo,
      "next_page": page,
      "matches_per_page": pageSize,
      "approval_percentage": 0.5,
    };
  }


  @override
  String toString() {
    return 'SearchParams(searchQuery: $searchQuery, dateFrom: $dateFrom, dateTo: $dateTo, '
        'selectedSources: $selectedSources, selectedTags: $selectedTags, '
        'searchInText: $searchInText, searchOption: $searchOption)';
  }
}