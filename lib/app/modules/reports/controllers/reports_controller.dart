import 'package:get/get.dart';
import '../../dashboard/repositories/dashboard_repository.dart';

class ReportsController extends GetxController {
  final DashboardRepository _repository;
  final isLoading = true.obs;
  final inboundChartData = <double>[].obs;
  final outboundChartData = <double>[].obs;

  ReportsController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    try {
      isLoading.value = true;
      final data = await _repository.getSummaryData();
      inboundChartData.assignAll(data['inboundChartData'] as List<double>);
      outboundChartData.assignAll(data['outboundChartData'] as List<double>);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu báo cáo: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
