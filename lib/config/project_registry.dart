import 'project_config.dart';
import 'projects/moneytherapist_config.dart';

class ProjectRegistry {
  ProjectRegistry._();

  static const ProjectConfig defaultProject = moneyTherapistConfig;

  static const Map<String, ProjectConfig> _projects = {
    'moneytherapist': moneyTherapistConfig,
  };

  static ProjectConfig resolve(String projectId) {
    final normalized = projectId.trim().toLowerCase();
    final project = _projects[normalized];

    if (project == null) {
      throw UnsupportedError('Unknown PROJECT_ID: $projectId');
    }

    return project;
  }
}
