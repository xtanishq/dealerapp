import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiService apiService;
  final StorageService storageService;


  List<DealerNotification> _notifications = [];
  int _skip = 0;
  final int _take = 10;

  String? _currentType;
  String? _currentCategory;
  String? _currentLanguage;

  NotificationBloc({
    required this.apiService,
    required this.storageService,
  }) : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<LoadMoreNotificationsEvent>(_onLoadMoreNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      _currentType = event.type;
      _currentCategory = event.category;
      _currentLanguage = event.language;
      _skip = 0; // Reset pagination offset

      final token = await storageService.getToken();
      if (token == null) {
        emit(NotificationUnauthorized());
        return;
      }

      final notifications = await apiService.getNotifications(
        token: token,
        type: _currentType,
        category: _currentCategory,
        language: _currentLanguage,
        skip: _skip,
        take: _take,
      );

      _notifications = notifications;
      _skip += notifications.length;

      emit(NotificationLoaded(
        _notifications,
        hasMore: notifications.length == _take,
      ));
    } on UnauthorizedException {
      emit(NotificationUnauthorized());
    } catch (e) {
      emit(NotificationError('Failed to load notifications'));
    }
  }


  Future<void> _onLoadMoreNotifications(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      emit(NotificationLoadingMore(_notifications));

      try {
        // Get authentication token
        final token = await storageService.getToken();
        if (token == null) {
          emit(NotificationUnauthorized());
          return;
        }

        final notifications = await apiService.getNotifications(
          token: token,
          type: _currentType,
          category: _currentCategory,
          language: _currentLanguage,
          skip: _skip,
          take: _take,
        );

        _notifications.addAll(notifications);
        _skip += notifications.length;

        emit(NotificationLoaded(
          _notifications,
          hasMore: notifications.length == _take, // Check if more items exist
        ));
      } on UnauthorizedException {
        emit(NotificationUnauthorized());
      } catch (e) {
        emit(NotificationLoaded(_notifications));
      }
    }
  }


  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    _skip = 0;
    add(LoadNotificationsEvent(
      type: _currentType,
      category: _currentCategory,
      language: _currentLanguage,
    ));
  }
}
