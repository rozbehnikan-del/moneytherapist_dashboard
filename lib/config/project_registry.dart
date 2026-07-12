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
    return _projects[normalized] ?? defaultProject;
  }
}
