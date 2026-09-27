import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme/hero_colors.dart';
import '../../core/models/models.dart';
import '../../widgets/hero_widgets.dart';

enum PeopleKind { students, teachers }

/// Paginated, searchable list of students or teachers (`GET /students`, `GET /teachers`).
class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key, required this.kind});

  final PeopleKind kind;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  int _page = 1;
  String _query = '';
  Timer? _debounce;
  Future<PagedList<Person>>? _future;

  bool get _isStudents => widget.kind == PeopleKind.students;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  @override
  void didUpdateWidget(PeoplePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) {
      _page = 1;
      _query = '';
      _future = _load();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<PagedList<Person>> _load() {
    final school = AppScope.of(context).school;
    return _isStudents ? school.students(page: _page, q: _query) : school.teachers(page: _page, q: _query);
  }

  void _goTo(int page) => setState(() {
    _page = page;
    _future = _load();
  });

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = value;
        _page = 1;
        _future = _load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final wide = MediaQuery.sizeOf(context).width >= 760;

    return PageBody(
      children: [
        PageHeader(
          title: _isStudents ? 'Students' : 'Teachers',
          description: _isStudents ? 'Everyone enrolled at your school.' : 'Teaching staff and their specializations.',
        ),
        HeroCard(
          padding: 0,
          child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              final page = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: TextField(
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                hintText: _isStudents ? 'Search by name, email or code' : 'Search by name or subject',
                                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_alt_outlined, size: 18),
                          label: Text(wide ? (_isStudents ? 'Add student' : 'Add teacher') : 'Add'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: hero.surfaceSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: _Row(
                      wide: wide,
                      isHeader: true,
                      cells: _isStudents
                          ? const ['Student', 'Code', 'Gender', 'Admitted', 'Email']
                          : const ['Teacher', 'Employee code', 'Specialization', 'Hired', 'Phone'],
                    ),
                  ),
                  if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        "Couldn't load data: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: hero.muted),
                      ),
                    )
                  else if (page != null && page.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'No records found.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: hero.muted),
                      ),
                    )
                  else if (page != null)
                    for (final person in page.items) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: _Row(wide: wide, person: person, isStudent: _isStudents),
                      ),
                      const Divider(),
                    ]
                  else
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            page == null ? '' : '${page.total} total · page ${page.page} of ${page.totalPages}',
                            style: TextStyle(fontSize: 14, color: hero.muted),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: page != null && page.page > 1 ? () => _goTo(page.page - 1) : null,
                          icon: const Icon(Icons.chevron_left_rounded, size: 18),
                          label: const Text('Previous'),
                        ),
                        TextButton.icon(
                          onPressed: page != null && page.page < page.totalPages ? () => _goTo(page.page + 1) : null,
                          icon: const Icon(Icons.chevron_right_rounded, size: 18),
                          iconAlignment: IconAlignment.end,
                          label: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.wide, this.cells, this.person, this.isStudent = true, this.isHeader = false});

  final bool wide;
  final List<String>? cells;
  final Person? person;
  final bool isStudent;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final headerStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: hero.muted);
    const cellStyle = TextStyle(fontSize: 14);

    Widget cell(int index) {
      if (isHeader) return Text(cells![index], style: headerStyle);
      final p = person!;
      return switch (index) {
        0 => Row(
          children: [
            HeroAvatar(p.user.initials, tone: isStudent ? Tone.accent : Tone.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    p.user.email,
                    style: TextStyle(fontSize: 12, color: hero.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        1 => Text(p.code, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
        2 =>
          isStudent
              ? Text(p.detail == null ? '—' : p.detail![0].toUpperCase() + p.detail!.substring(1), style: cellStyle)
              : Align(alignment: Alignment.centerLeft, child: HeroChip(p.detail ?? '—')),
        3 => Text(p.date ?? '—', style: cellStyle),
        _ =>
          isStudent
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: HeroChip(
                    p.user.emailVerified ? 'Verified' : 'Pending',
                    tone: p.user.emailVerified ? Tone.success : Tone.warning,
                  ),
                )
              : Text(p.user.phone ?? '—', style: cellStyle),
      };
    }

    if (!wide) {
      // Phones: the name cell plus the code, stacked.
      return Row(
        children: [
          Expanded(child: cell(0)),
          if (!isHeader) cell(1),
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: 4, child: cell(0)),
        Expanded(flex: 2, child: cell(1)),
        Expanded(flex: 2, child: cell(2)),
        Expanded(flex: 2, child: cell(3)),
        Expanded(flex: 2, child: cell(4)),
      ],
    );
  }
}
