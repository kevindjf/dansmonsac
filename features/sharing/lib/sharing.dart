/// Sharing feature module - allows users to share schedules via code
library sharing;

// Models
export 'models/shared_schedule.dart';
export 'models/shared_schedule_data.dart';
export 'models/import_result.dart';

// Repository
export 'repository/sharing_repository.dart';

// Services
export 'services/code_generator.dart';
export 'services/deep_link_service.dart';

// DI
export 'di/riverpod_di.dart';

// Presentation
export 'presentation/share/share_page.dart';
export 'presentation/import/import_preview_page.dart';
export 'presentation/import/import_conflict_dialog.dart';
export 'presentation/widgets/code_input_widget.dart';
