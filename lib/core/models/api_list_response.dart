class APIListResponse<T> {
  int status;
  String message;
  List<T> data;
  int total;
  int pageSize;
  int pageNo;
  bool isFwList;
  bool isFwController;

  APIListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.total,
    required this.pageSize,
    required this.pageNo,
    required this.isFwList,
    required this.isFwController,
  });

  factory APIListResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return APIListResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? List<T>.from(json["data"].map((x) => fromJsonT(x)))
          : [],
      total: json["total"] ?? 0,
      pageSize: json["pageSize"] ?? 0,
      pageNo: json["pageNo"] ?? 0,
      isFwList: json["_fw_list"] ?? false,
      isFwController: json["_fw_consoller"] ?? false,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => toJsonT(x))),
        "total": total,
        "pageSize": pageSize,
        "pageNo": pageNo,
        "_fw_list": isFwList,
        "_fw_consoller": isFwController,
      };

  @override
  String toString() {
    return 'APIListResponse(status: $status, message: $message, total: $total, pageSize: $pageSize, pageNo: $pageNo, data: $data)';
  }

  bool get isSuccess => status >= 200 && status < 300;
}
