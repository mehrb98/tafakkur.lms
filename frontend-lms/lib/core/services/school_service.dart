import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../models/models.dart';
import 'demo_data.dart';

class SchoolCounts {
  const SchoolCounts({required this.students, required this.teachers, required this.parents, required this.classes});

  final int students;
  final int teachers;
  final int parents;
  final int classes;
}

/// Reads school data from the Rails API, or from in-app demo data when the
/// user entered through a demo role.
class SchoolService {
  SchoolService(this.api, this.auth);

  final ApiClient api;
  final AuthController auth;

  Future<int> _count(String path) async {
    final body = await api.get(path, {'limit': 1}) as Map<String, dynamic>;
    return (body['meta'] as Map<String, dynamic>)['total'] as int;
  }

  Future<SchoolCounts> counts() async {
    if (auth.isDemo) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return const SchoolCounts(students: 1248, teachers: 86, parents: 1032, classes: 42);
    }
    final results = await Future.wait([
      _count('/students'),
      _count('/teachers'),
      _count('/parents'),
      _count('/classes'),
    ]);
    return SchoolCounts(students: results[0], teachers: results[1], parents: results[2], classes: results[3]);
  }

  Future<PagedList<Person>> students({int page = 1, int limit = 10, String q = ''}) =>
      _people('/students', Person.studentFromJson, demoStudents, page: page, limit: limit, q: q);

  Future<PagedList<Person>> teachers({int page = 1, int limit = 10, String q = ''}) =>
      _people('/teachers', Person.teacherFromJson, demoTeachers, page: page, limit: limit, q: q);

  Future<PagedList<Person>> _people(
    String path,
    Person Function(Map<String, dynamic>) parse,
    List<Person> demo, {
    required int page,
    required int limit,
    required String q,
  }) async {
    if (auth.isDemo) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return paginateDemo(demo, page: page, limit: limit, q: q);
    }
    final body = await api.get(path, {'page': page, 'limit': limit, 'q': q}) as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>;
    return PagedList(
      items: (body['data'] as List).cast<Map<String, dynamic>>().map(parse).toList(),
      page: meta['page'] as int,
      totalPages: meta['total_pages'] as int,
      total: meta['total'] as int,
    );
  }
}
