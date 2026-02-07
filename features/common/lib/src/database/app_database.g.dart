// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CoursesTable extends Courses
    with TableInfo<$CoursesTable, CourseEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weekTypeMeta =
      const VerificationMeta('weekType');
  @override
  late final GeneratedColumn<String> weekType = GeneratedColumn<String>(
      'week_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, remoteId, name, color, weekType, updatedAt, isSynced, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(Insertable<CourseEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('week_type')) {
      context.handle(_weekTypeMeta,
          weekType.isAcceptableOrUnknown(data['week_type']!, _weekTypeMeta));
    } else if (isInserting) {
      context.missing(_weekTypeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      weekType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}week_type'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class CourseEntity extends DataClass implements Insertable<CourseEntity> {
  final String id;
  final String? remoteId;
  final String name;
  final String color;
  final String weekType;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime createdAt;
  const CourseEntity(
      {required this.id,
      this.remoteId,
      required this.name,
      required this.color,
      required this.weekType,
      required this.updatedAt,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['week_type'] = Variable<String>(weekType);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      name: Value(name),
      color: Value(color),
      weekType: Value(weekType),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory CourseEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseEntity(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      weekType: serializer.fromJson<String>(json['weekType']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'weekType': serializer.toJson<String>(weekType),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CourseEntity copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? name,
          String? color,
          String? weekType,
          DateTime? updatedAt,
          bool? isSynced,
          DateTime? createdAt}) =>
      CourseEntity(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        name: name ?? this.name,
        color: color ?? this.color,
        weekType: weekType ?? this.weekType,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  CourseEntity copyWithCompanion(CoursesCompanion data) {
    return CourseEntity(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      weekType: data.weekType.present ? data.weekType.value : this.weekType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseEntity(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('weekType: $weekType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, remoteId, name, color, weekType, updatedAt, isSynced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseEntity &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.color == this.color &&
          other.weekType == this.weekType &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class CoursesCompanion extends UpdateCompanion<CourseEntity> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> name;
  final Value<String> color;
  final Value<String> weekType;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.weekType = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String name,
    required String color,
    required String weekType,
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        color = Value(color),
        weekType = Value(weekType),
        updatedAt = Value(updatedAt);
  static Insertable<CourseEntity> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? weekType,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (weekType != null) 'week_type': weekType,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? name,
      Value<String>? color,
      Value<String>? weekType,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CoursesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      color: color ?? this.color,
      weekType: weekType ?? this.weekType,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (weekType.present) {
      map['week_type'] = Variable<String>(weekType.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('weekType: $weekType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliesTable extends Supplies
    with TableInfo<$SuppliesTable, SupplyEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _checkedDateMeta =
      const VerificationMeta('checkedDate');
  @override
  late final GeneratedColumn<DateTime> checkedDate = GeneratedColumn<DateTime>(
      'checked_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        courseId,
        name,
        isChecked,
        checkedDate,
        updatedAt,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplies';
  @override
  VerificationContext validateIntegrity(Insertable<SupplyEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('checked_date')) {
      context.handle(
          _checkedDateMeta,
          checkedDate.isAcceptableOrUnknown(
              data['checked_date']!, _checkedDateMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplyEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplyEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      checkedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}checked_date']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SuppliesTable createAlias(String alias) {
    return $SuppliesTable(attachedDatabase, alias);
  }
}

class SupplyEntity extends DataClass implements Insertable<SupplyEntity> {
  final String id;
  final String? remoteId;
  final String courseId;
  final String name;
  final bool isChecked;
  final DateTime? checkedDate;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime createdAt;
  const SupplyEntity(
      {required this.id,
      this.remoteId,
      required this.courseId,
      required this.name,
      required this.isChecked,
      this.checkedDate,
      required this.updatedAt,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['course_id'] = Variable<String>(courseId);
    map['name'] = Variable<String>(name);
    map['is_checked'] = Variable<bool>(isChecked);
    if (!nullToAbsent || checkedDate != null) {
      map['checked_date'] = Variable<DateTime>(checkedDate);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuppliesCompanion toCompanion(bool nullToAbsent) {
    return SuppliesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      courseId: Value(courseId),
      name: Value(name),
      isChecked: Value(isChecked),
      checkedDate: checkedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedDate),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory SupplyEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplyEntity(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      name: serializer.fromJson<String>(json['name']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      checkedDate: serializer.fromJson<DateTime?>(json['checkedDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'courseId': serializer.toJson<String>(courseId),
      'name': serializer.toJson<String>(name),
      'isChecked': serializer.toJson<bool>(isChecked),
      'checkedDate': serializer.toJson<DateTime?>(checkedDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupplyEntity copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? courseId,
          String? name,
          bool? isChecked,
          Value<DateTime?> checkedDate = const Value.absent(),
          DateTime? updatedAt,
          bool? isSynced,
          DateTime? createdAt}) =>
      SupplyEntity(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        courseId: courseId ?? this.courseId,
        name: name ?? this.name,
        isChecked: isChecked ?? this.isChecked,
        checkedDate: checkedDate.present ? checkedDate.value : this.checkedDate,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  SupplyEntity copyWithCompanion(SuppliesCompanion data) {
    return SupplyEntity(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      name: data.name.present ? data.name.value : this.name,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      checkedDate:
          data.checkedDate.present ? data.checkedDate.value : this.checkedDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplyEntity(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('courseId: $courseId, ')
          ..write('name: $name, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedDate: $checkedDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, courseId, name, isChecked,
      checkedDate, updatedAt, isSynced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplyEntity &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.courseId == this.courseId &&
          other.name == this.name &&
          other.isChecked == this.isChecked &&
          other.checkedDate == this.checkedDate &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class SuppliesCompanion extends UpdateCompanion<SupplyEntity> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> courseId;
  final Value<String> name;
  final Value<bool> isChecked;
  final Value<DateTime?> checkedDate;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SuppliesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.name = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.checkedDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliesCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String courseId,
    required String name,
    this.isChecked = const Value.absent(),
    this.checkedDate = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        courseId = Value(courseId),
        name = Value(name),
        updatedAt = Value(updatedAt);
  static Insertable<SupplyEntity> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? courseId,
    Expression<String>? name,
    Expression<bool>? isChecked,
    Expression<DateTime>? checkedDate,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (courseId != null) 'course_id': courseId,
      if (name != null) 'name': name,
      if (isChecked != null) 'is_checked': isChecked,
      if (checkedDate != null) 'checked_date': checkedDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? courseId,
      Value<String>? name,
      Value<bool>? isChecked,
      Value<DateTime?>? checkedDate,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SuppliesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      checkedDate: checkedDate ?? this.checkedDate,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (checkedDate.present) {
      map['checked_date'] = Variable<DateTime>(checkedDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('courseId: $courseId, ')
          ..write('name: $name, ')
          ..write('isChecked: $isChecked, ')
          ..write('checkedDate: $checkedDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarCoursesTable extends CalendarCourses
    with TableInfo<$CalendarCoursesTable, CalendarCourseEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomNameMeta =
      const VerificationMeta('roomName');
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
      'room_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startHourMeta =
      const VerificationMeta('startHour');
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
      'start_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startMinuteMeta =
      const VerificationMeta('startMinute');
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
      'start_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endHourMeta =
      const VerificationMeta('endHour');
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
      'end_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMinuteMeta =
      const VerificationMeta('endMinute');
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
      'end_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weekTypeMeta =
      const VerificationMeta('weekType');
  @override
  late final GeneratedColumn<String> weekType = GeneratedColumn<String>(
      'week_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AB'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        courseId,
        roomName,
        dayOfWeek,
        startHour,
        startMinute,
        endHour,
        endMinute,
        weekType,
        updatedAt,
        isSynced,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_courses';
  @override
  VerificationContext validateIntegrity(
      Insertable<CalendarCourseEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('room_name')) {
      context.handle(_roomNameMeta,
          roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta));
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_hour')) {
      context.handle(_startHourMeta,
          startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta));
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
          _startMinuteMeta,
          startMinute.isAcceptableOrUnknown(
              data['start_minute']!, _startMinuteMeta));
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(_endHourMeta,
          endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta));
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(_endMinuteMeta,
          endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta));
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('week_type')) {
      context.handle(_weekTypeMeta,
          weekType.isAcceptableOrUnknown(data['week_type']!, _weekTypeMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarCourseEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarCourseEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      roomName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_name'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      startHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_hour'])!,
      startMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_minute'])!,
      endHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_hour'])!,
      endMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_minute'])!,
      weekType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}week_type'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CalendarCoursesTable createAlias(String alias) {
    return $CalendarCoursesTable(attachedDatabase, alias);
  }
}

class CalendarCourseEntity extends DataClass
    implements Insertable<CalendarCourseEntity> {
  final String id;
  final String? remoteId;
  final String courseId;
  final String roomName;
  final int dayOfWeek;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String weekType;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime createdAt;
  const CalendarCourseEntity(
      {required this.id,
      this.remoteId,
      required this.courseId,
      required this.roomName,
      required this.dayOfWeek,
      required this.startHour,
      required this.startMinute,
      required this.endHour,
      required this.endMinute,
      required this.weekType,
      required this.updatedAt,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['course_id'] = Variable<String>(courseId);
    map['room_name'] = Variable<String>(roomName);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_hour'] = Variable<int>(startHour);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_hour'] = Variable<int>(endHour);
    map['end_minute'] = Variable<int>(endMinute);
    map['week_type'] = Variable<String>(weekType);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CalendarCoursesCompanion toCompanion(bool nullToAbsent) {
    return CalendarCoursesCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      courseId: Value(courseId),
      roomName: Value(roomName),
      dayOfWeek: Value(dayOfWeek),
      startHour: Value(startHour),
      startMinute: Value(startMinute),
      endHour: Value(endHour),
      endMinute: Value(endMinute),
      weekType: Value(weekType),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory CalendarCourseEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarCourseEntity(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      roomName: serializer.fromJson<String>(json['roomName']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startHour: serializer.fromJson<int>(json['startHour']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endHour: serializer.fromJson<int>(json['endHour']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      weekType: serializer.fromJson<String>(json['weekType']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'courseId': serializer.toJson<String>(courseId),
      'roomName': serializer.toJson<String>(roomName),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startHour': serializer.toJson<int>(startHour),
      'startMinute': serializer.toJson<int>(startMinute),
      'endHour': serializer.toJson<int>(endHour),
      'endMinute': serializer.toJson<int>(endMinute),
      'weekType': serializer.toJson<String>(weekType),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CalendarCourseEntity copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? courseId,
          String? roomName,
          int? dayOfWeek,
          int? startHour,
          int? startMinute,
          int? endHour,
          int? endMinute,
          String? weekType,
          DateTime? updatedAt,
          bool? isSynced,
          DateTime? createdAt}) =>
      CalendarCourseEntity(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        courseId: courseId ?? this.courseId,
        roomName: roomName ?? this.roomName,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        endHour: endHour ?? this.endHour,
        endMinute: endMinute ?? this.endMinute,
        weekType: weekType ?? this.weekType,
        updatedAt: updatedAt ?? this.updatedAt,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  CalendarCourseEntity copyWithCompanion(CalendarCoursesCompanion data) {
    return CalendarCourseEntity(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      startMinute:
          data.startMinute.present ? data.startMinute.value : this.startMinute,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      weekType: data.weekType.present ? data.weekType.value : this.weekType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarCourseEntity(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('courseId: $courseId, ')
          ..write('roomName: $roomName, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('weekType: $weekType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remoteId,
      courseId,
      roomName,
      dayOfWeek,
      startHour,
      startMinute,
      endHour,
      endMinute,
      weekType,
      updatedAt,
      isSynced,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarCourseEntity &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.courseId == this.courseId &&
          other.roomName == this.roomName &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startHour == this.startHour &&
          other.startMinute == this.startMinute &&
          other.endHour == this.endHour &&
          other.endMinute == this.endMinute &&
          other.weekType == this.weekType &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class CalendarCoursesCompanion extends UpdateCompanion<CalendarCourseEntity> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> courseId;
  final Value<String> roomName;
  final Value<int> dayOfWeek;
  final Value<int> startHour;
  final Value<int> startMinute;
  final Value<int> endHour;
  final Value<int> endMinute;
  final Value<String> weekType;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CalendarCoursesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startHour = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endHour = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.weekType = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarCoursesCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    required String courseId,
    this.roomName = const Value.absent(),
    required int dayOfWeek,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    this.weekType = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        courseId = Value(courseId),
        dayOfWeek = Value(dayOfWeek),
        startHour = Value(startHour),
        startMinute = Value(startMinute),
        endHour = Value(endHour),
        endMinute = Value(endMinute),
        updatedAt = Value(updatedAt);
  static Insertable<CalendarCourseEntity> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? courseId,
    Expression<String>? roomName,
    Expression<int>? dayOfWeek,
    Expression<int>? startHour,
    Expression<int>? startMinute,
    Expression<int>? endHour,
    Expression<int>? endMinute,
    Expression<String>? weekType,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (courseId != null) 'course_id': courseId,
      if (roomName != null) 'room_name': roomName,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startHour != null) 'start_hour': startHour,
      if (startMinute != null) 'start_minute': startMinute,
      if (endHour != null) 'end_hour': endHour,
      if (endMinute != null) 'end_minute': endMinute,
      if (weekType != null) 'week_type': weekType,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarCoursesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? courseId,
      Value<String>? roomName,
      Value<int>? dayOfWeek,
      Value<int>? startHour,
      Value<int>? startMinute,
      Value<int>? endHour,
      Value<int>? endMinute,
      Value<String>? weekType,
      Value<DateTime>? updatedAt,
      Value<bool>? isSynced,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CalendarCoursesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      courseId: courseId ?? this.courseId,
      roomName: roomName ?? this.roomName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      weekType: weekType ?? this.weekType,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (weekType.present) {
      map['week_type'] = Variable<String>(weekType.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarCoursesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('courseId: $courseId, ')
          ..write('roomName: $roomName, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('weekType: $weekType, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperationEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationTypeMeta =
      const VerificationMeta('operationType');
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
      'operation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, operationType, data, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingOperationEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
          _operationTypeMeta,
          operationType.isAcceptableOrUnknown(
              data['operation_type']!, _operationTypeMeta));
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperationEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperationEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_type'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOperationEntity extends DataClass
    implements Insertable<PendingOperationEntity> {
  final String id;
  final String entityType;
  final String entityId;
  final String operationType;
  final String? data;
  final DateTime createdAt;
  final int retryCount;
  const PendingOperationEntity(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operationType,
      this.data,
      required this.createdAt,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory PendingOperationEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperationEntity(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      data: serializer.fromJson<String?>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'data': serializer.toJson<String?>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PendingOperationEntity copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? operationType,
          Value<String?> data = const Value.absent(),
          DateTime? createdAt,
          int? retryCount}) =>
      PendingOperationEntity(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operationType: operationType ?? this.operationType,
        data: data.present ? data.value : this.data,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
      );
  PendingOperationEntity copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperationEntity(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationEntity(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, operationType, data, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperationEntity &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PendingOperationsCompanion
    extends UpdateCompanion<PendingOperationEntity> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String?> data;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<int> rowid;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operationType,
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operationType = Value(operationType);
  static Insertable<PendingOperationEntity> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOperationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operationType,
      Value<String?>? data,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<int>? rowid}) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyChecksTable extends DailyChecks
    with TableInfo<$DailyChecksTable, DailyCheckEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _supplyIdMeta =
      const VerificationMeta('supplyId');
  @override
  late final GeneratedColumn<String> supplyId = GeneratedColumn<String>(
      'supply_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, supplyId, courseId, isChecked, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_checks';
  @override
  VerificationContext validateIntegrity(Insertable<DailyCheckEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('supply_id')) {
      context.handle(_supplyIdMeta,
          supplyId.isAcceptableOrUnknown(data['supply_id']!, _supplyIdMeta));
    } else if (isInserting) {
      context.missing(_supplyIdMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyCheckEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCheckEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      supplyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supply_id'])!,
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DailyChecksTable createAlias(String alias) {
    return $DailyChecksTable(attachedDatabase, alias);
  }
}

class DailyCheckEntity extends DataClass
    implements Insertable<DailyCheckEntity> {
  final String id;
  final DateTime date;
  final String supplyId;
  final String courseId;
  final bool isChecked;
  final DateTime createdAt;
  const DailyCheckEntity(
      {required this.id,
      required this.date,
      required this.supplyId,
      required this.courseId,
      required this.isChecked,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['supply_id'] = Variable<String>(supplyId);
    map['course_id'] = Variable<String>(courseId);
    map['is_checked'] = Variable<bool>(isChecked);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyChecksCompanion toCompanion(bool nullToAbsent) {
    return DailyChecksCompanion(
      id: Value(id),
      date: Value(date),
      supplyId: Value(supplyId),
      courseId: Value(courseId),
      isChecked: Value(isChecked),
      createdAt: Value(createdAt),
    );
  }

  factory DailyCheckEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCheckEntity(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      supplyId: serializer.fromJson<String>(json['supplyId']),
      courseId: serializer.fromJson<String>(json['courseId']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'supplyId': serializer.toJson<String>(supplyId),
      'courseId': serializer.toJson<String>(courseId),
      'isChecked': serializer.toJson<bool>(isChecked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyCheckEntity copyWith(
          {String? id,
          DateTime? date,
          String? supplyId,
          String? courseId,
          bool? isChecked,
          DateTime? createdAt}) =>
      DailyCheckEntity(
        id: id ?? this.id,
        date: date ?? this.date,
        supplyId: supplyId ?? this.supplyId,
        courseId: courseId ?? this.courseId,
        isChecked: isChecked ?? this.isChecked,
        createdAt: createdAt ?? this.createdAt,
      );
  DailyCheckEntity copyWithCompanion(DailyChecksCompanion data) {
    return DailyCheckEntity(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      supplyId: data.supplyId.present ? data.supplyId.value : this.supplyId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckEntity(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('supplyId: $supplyId, ')
          ..write('courseId: $courseId, ')
          ..write('isChecked: $isChecked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, supplyId, courseId, isChecked, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCheckEntity &&
          other.id == this.id &&
          other.date == this.date &&
          other.supplyId == this.supplyId &&
          other.courseId == this.courseId &&
          other.isChecked == this.isChecked &&
          other.createdAt == this.createdAt);
}

class DailyChecksCompanion extends UpdateCompanion<DailyCheckEntity> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> supplyId;
  final Value<String> courseId;
  final Value<bool> isChecked;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyChecksCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.supplyId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyChecksCompanion.insert({
    required String id,
    required DateTime date,
    required String supplyId,
    required String courseId,
    this.isChecked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        supplyId = Value(supplyId),
        courseId = Value(courseId);
  static Insertable<DailyCheckEntity> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? supplyId,
    Expression<String>? courseId,
    Expression<bool>? isChecked,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (supplyId != null) 'supply_id': supplyId,
      if (courseId != null) 'course_id': courseId,
      if (isChecked != null) 'is_checked': isChecked,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyChecksCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String>? supplyId,
      Value<String>? courseId,
      Value<bool>? isChecked,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DailyChecksCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      supplyId: supplyId ?? this.supplyId,
      courseId: courseId ?? this.courseId,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (supplyId.present) {
      map['supply_id'] = Variable<String>(supplyId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyChecksCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('supplyId: $supplyId, ')
          ..write('courseId: $courseId, ')
          ..write('isChecked: $isChecked, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BagCompletionsTable extends BagCompletions
    with TableInfo<$BagCompletionsTable, BagCompletionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BagCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, completedAt, deviceId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bag_completions';
  @override
  VerificationContext validateIntegrity(
      Insertable<BagCompletionEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BagCompletionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BagCompletionEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BagCompletionsTable createAlias(String alias) {
    return $BagCompletionsTable(attachedDatabase, alias);
  }
}

class BagCompletionEntity extends DataClass
    implements Insertable<BagCompletionEntity> {
  final String id;
  final DateTime date;
  final DateTime completedAt;
  final String deviceId;
  final DateTime createdAt;
  const BagCompletionEntity(
      {required this.id,
      required this.date,
      required this.completedAt,
      required this.deviceId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BagCompletionsCompanion toCompanion(bool nullToAbsent) {
    return BagCompletionsCompanion(
      id: Value(id),
      date: Value(date),
      completedAt: Value(completedAt),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
    );
  }

  factory BagCompletionEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BagCompletionEntity(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BagCompletionEntity copyWith(
          {String? id,
          DateTime? date,
          DateTime? completedAt,
          String? deviceId,
          DateTime? createdAt}) =>
      BagCompletionEntity(
        id: id ?? this.id,
        date: date ?? this.date,
        completedAt: completedAt ?? this.completedAt,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
      );
  BagCompletionEntity copyWithCompanion(BagCompletionsCompanion data) {
    return BagCompletionEntity(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BagCompletionEntity(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, completedAt, deviceId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BagCompletionEntity &&
          other.id == this.id &&
          other.date == this.date &&
          other.completedAt == this.completedAt &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt);
}

class BagCompletionsCompanion extends UpdateCompanion<BagCompletionEntity> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<DateTime> completedAt;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BagCompletionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BagCompletionsCompanion.insert({
    required String id,
    required DateTime date,
    required DateTime completedAt,
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        completedAt = Value(completedAt),
        deviceId = Value(deviceId);
  static Insertable<BagCompletionEntity> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<DateTime>? completedAt,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (completedAt != null) 'completed_at': completedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BagCompletionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<DateTime>? completedAt,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BagCompletionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BagCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PremiumStatusTable extends PremiumStatus
    with TableInfo<$PremiumStatusTable, PremiumStatusEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PremiumStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasPurchasedMeta =
      const VerificationMeta('hasPurchased');
  @override
  late final GeneratedColumn<bool> hasPurchased = GeneratedColumn<bool>(
      'has_purchased', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_purchased" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _linkedParentIdMeta =
      const VerificationMeta('linkedParentId');
  @override
  late final GeneratedColumn<String> linkedParentId = GeneratedColumn<String>(
      'linked_parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, hasPurchased, linkedParentId, updatedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'premium_status';
  @override
  VerificationContext validateIntegrity(
      Insertable<PremiumStatusEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('has_purchased')) {
      context.handle(
          _hasPurchasedMeta,
          hasPurchased.isAcceptableOrUnknown(
              data['has_purchased']!, _hasPurchasedMeta));
    }
    if (data.containsKey('linked_parent_id')) {
      context.handle(
          _linkedParentIdMeta,
          linkedParentId.isAcceptableOrUnknown(
              data['linked_parent_id']!, _linkedParentIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PremiumStatusEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PremiumStatusEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hasPurchased: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_purchased'])!,
      linkedParentId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_parent_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PremiumStatusTable createAlias(String alias) {
    return $PremiumStatusTable(attachedDatabase, alias);
  }
}

class PremiumStatusEntity extends DataClass
    implements Insertable<PremiumStatusEntity> {
  final String id;
  final bool hasPurchased;
  final String? linkedParentId;
  final DateTime updatedAt;
  final DateTime createdAt;
  const PremiumStatusEntity(
      {required this.id,
      required this.hasPurchased,
      this.linkedParentId,
      required this.updatedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['has_purchased'] = Variable<bool>(hasPurchased);
    if (!nullToAbsent || linkedParentId != null) {
      map['linked_parent_id'] = Variable<String>(linkedParentId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PremiumStatusCompanion toCompanion(bool nullToAbsent) {
    return PremiumStatusCompanion(
      id: Value(id),
      hasPurchased: Value(hasPurchased),
      linkedParentId: linkedParentId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedParentId),
      updatedAt: Value(updatedAt),
      createdAt: Value(createdAt),
    );
  }

  factory PremiumStatusEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PremiumStatusEntity(
      id: serializer.fromJson<String>(json['id']),
      hasPurchased: serializer.fromJson<bool>(json['hasPurchased']),
      linkedParentId: serializer.fromJson<String?>(json['linkedParentId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hasPurchased': serializer.toJson<bool>(hasPurchased),
      'linkedParentId': serializer.toJson<String?>(linkedParentId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PremiumStatusEntity copyWith(
          {String? id,
          bool? hasPurchased,
          Value<String?> linkedParentId = const Value.absent(),
          DateTime? updatedAt,
          DateTime? createdAt}) =>
      PremiumStatusEntity(
        id: id ?? this.id,
        hasPurchased: hasPurchased ?? this.hasPurchased,
        linkedParentId:
            linkedParentId.present ? linkedParentId.value : this.linkedParentId,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  PremiumStatusEntity copyWithCompanion(PremiumStatusCompanion data) {
    return PremiumStatusEntity(
      id: data.id.present ? data.id.value : this.id,
      hasPurchased: data.hasPurchased.present
          ? data.hasPurchased.value
          : this.hasPurchased,
      linkedParentId: data.linkedParentId.present
          ? data.linkedParentId.value
          : this.linkedParentId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PremiumStatusEntity(')
          ..write('id: $id, ')
          ..write('hasPurchased: $hasPurchased, ')
          ..write('linkedParentId: $linkedParentId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, hasPurchased, linkedParentId, updatedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PremiumStatusEntity &&
          other.id == this.id &&
          other.hasPurchased == this.hasPurchased &&
          other.linkedParentId == this.linkedParentId &&
          other.updatedAt == this.updatedAt &&
          other.createdAt == this.createdAt);
}

class PremiumStatusCompanion extends UpdateCompanion<PremiumStatusEntity> {
  final Value<String> id;
  final Value<bool> hasPurchased;
  final Value<String?> linkedParentId;
  final Value<DateTime> updatedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PremiumStatusCompanion({
    this.id = const Value.absent(),
    this.hasPurchased = const Value.absent(),
    this.linkedParentId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PremiumStatusCompanion.insert({
    required String id,
    this.hasPurchased = const Value.absent(),
    this.linkedParentId = const Value.absent(),
    required DateTime updatedAt,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt);
  static Insertable<PremiumStatusEntity> custom({
    Expression<String>? id,
    Expression<bool>? hasPurchased,
    Expression<String>? linkedParentId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hasPurchased != null) 'has_purchased': hasPurchased,
      if (linkedParentId != null) 'linked_parent_id': linkedParentId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PremiumStatusCompanion copyWith(
      {Value<String>? id,
      Value<bool>? hasPurchased,
      Value<String?>? linkedParentId,
      Value<DateTime>? updatedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PremiumStatusCompanion(
      id: id ?? this.id,
      hasPurchased: hasPurchased ?? this.hasPurchased,
      linkedParentId: linkedParentId ?? this.linkedParentId,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hasPurchased.present) {
      map['has_purchased'] = Variable<bool>(hasPurchased.value);
    }
    if (linkedParentId.present) {
      map['linked_parent_id'] = Variable<String>(linkedParentId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PremiumStatusCompanion(')
          ..write('id: $id, ')
          ..write('hasPurchased: $hasPurchased, ')
          ..write('linkedParentId: $linkedParentId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $SuppliesTable supplies = $SuppliesTable(this);
  late final $CalendarCoursesTable calendarCourses =
      $CalendarCoursesTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $DailyChecksTable dailyChecks = $DailyChecksTable(this);
  late final $BagCompletionsTable bagCompletions = $BagCompletionsTable(this);
  late final $PremiumStatusTable premiumStatus = $PremiumStatusTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        courses,
        supplies,
        calendarCourses,
        pendingOperations,
        dailyChecks,
        bagCompletions,
        premiumStatus
      ];
}

typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  required String id,
  Value<String?> remoteId,
  required String name,
  required String color,
  required String weekType,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> name,
  Value<String> color,
  Value<String> weekType,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekType => $composableBuilder(
      column: $table.weekType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekType => $composableBuilder(
      column: $table.weekType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get weekType =>
      $composableBuilder(column: $table.weekType, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CoursesTable,
    CourseEntity,
    $$CoursesTableFilterComposer,
    $$CoursesTableOrderingComposer,
    $$CoursesTableAnnotationComposer,
    $$CoursesTableCreateCompanionBuilder,
    $$CoursesTableUpdateCompanionBuilder,
    (CourseEntity, BaseReferences<_$AppDatabase, $CoursesTable, CourseEntity>),
    CourseEntity,
    PrefetchHooks Function()> {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String> weekType = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CoursesCompanion(
            id: id,
            remoteId: remoteId,
            name: name,
            color: color,
            weekType: weekType,
            updatedAt: updatedAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String name,
            required String color,
            required String weekType,
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CoursesCompanion.insert(
            id: id,
            remoteId: remoteId,
            name: name,
            color: color,
            weekType: weekType,
            updatedAt: updatedAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CoursesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CoursesTable,
    CourseEntity,
    $$CoursesTableFilterComposer,
    $$CoursesTableOrderingComposer,
    $$CoursesTableAnnotationComposer,
    $$CoursesTableCreateCompanionBuilder,
    $$CoursesTableUpdateCompanionBuilder,
    (CourseEntity, BaseReferences<_$AppDatabase, $CoursesTable, CourseEntity>),
    CourseEntity,
    PrefetchHooks Function()>;
typedef $$SuppliesTableCreateCompanionBuilder = SuppliesCompanion Function({
  required String id,
  Value<String?> remoteId,
  required String courseId,
  required String name,
  Value<bool> isChecked,
  Value<DateTime?> checkedDate,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SuppliesTableUpdateCompanionBuilder = SuppliesCompanion Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> courseId,
  Value<String> name,
  Value<bool> isChecked,
  Value<DateTime?> checkedDate,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkedDate => $composableBuilder(
      column: $table.checkedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkedDate => $composableBuilder(
      column: $table.checkedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedDate => $composableBuilder(
      column: $table.checkedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SuppliesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliesTable,
    SupplyEntity,
    $$SuppliesTableFilterComposer,
    $$SuppliesTableOrderingComposer,
    $$SuppliesTableAnnotationComposer,
    $$SuppliesTableCreateCompanionBuilder,
    $$SuppliesTableUpdateCompanionBuilder,
    (SupplyEntity, BaseReferences<_$AppDatabase, $SuppliesTable, SupplyEntity>),
    SupplyEntity,
    PrefetchHooks Function()> {
  $$SuppliesTableTableManager(_$AppDatabase db, $SuppliesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<DateTime?> checkedDate = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliesCompanion(
            id: id,
            remoteId: remoteId,
            courseId: courseId,
            name: name,
            isChecked: isChecked,
            checkedDate: checkedDate,
            updatedAt: updatedAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String courseId,
            required String name,
            Value<bool> isChecked = const Value.absent(),
            Value<DateTime?> checkedDate = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliesCompanion.insert(
            id: id,
            remoteId: remoteId,
            courseId: courseId,
            name: name,
            isChecked: isChecked,
            checkedDate: checkedDate,
            updatedAt: updatedAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SuppliesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliesTable,
    SupplyEntity,
    $$SuppliesTableFilterComposer,
    $$SuppliesTableOrderingComposer,
    $$SuppliesTableAnnotationComposer,
    $$SuppliesTableCreateCompanionBuilder,
    $$SuppliesTableUpdateCompanionBuilder,
    (SupplyEntity, BaseReferences<_$AppDatabase, $SuppliesTable, SupplyEntity>),
    SupplyEntity,
    PrefetchHooks Function()>;
typedef $$CalendarCoursesTableCreateCompanionBuilder = CalendarCoursesCompanion
    Function({
  required String id,
  Value<String?> remoteId,
  required String courseId,
  Value<String> roomName,
  required int dayOfWeek,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  Value<String> weekType,
  required DateTime updatedAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CalendarCoursesTableUpdateCompanionBuilder = CalendarCoursesCompanion
    Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> courseId,
  Value<String> roomName,
  Value<int> dayOfWeek,
  Value<int> startHour,
  Value<int> startMinute,
  Value<int> endHour,
  Value<int> endMinute,
  Value<String> weekType,
  Value<DateTime> updatedAt,
  Value<bool> isSynced,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CalendarCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarCoursesTable> {
  $$CalendarCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekType => $composableBuilder(
      column: $table.weekType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CalendarCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarCoursesTable> {
  $$CalendarCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomName => $composableBuilder(
      column: $table.roomName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekType => $composableBuilder(
      column: $table.weekType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CalendarCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarCoursesTable> {
  $$CalendarCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => column);

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get weekType =>
      $composableBuilder(column: $table.weekType, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CalendarCoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalendarCoursesTable,
    CalendarCourseEntity,
    $$CalendarCoursesTableFilterComposer,
    $$CalendarCoursesTableOrderingComposer,
    $$CalendarCoursesTableAnnotationComposer,
    $$CalendarCoursesTableCreateCompanionBuilder,
    $$CalendarCoursesTableUpdateCompanionBuilder,
    (
      CalendarCourseEntity,
      BaseReferences<_$AppDatabase, $CalendarCoursesTable, CalendarCourseEntity>
    ),
    CalendarCourseEntity,
    PrefetchHooks Function()> {
  $$CalendarCoursesTableTableManager(
      _$AppDatabase db, $CalendarCoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<String> roomName = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> startHour = const Value.absent(),
            Value<int> startMinute = const Value.absent(),
            Value<int> endHour = const Value.absent(),
            Value<int> endMinute = const Value.absent(),
            Value<String> weekType = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarCoursesCompanion(
            id: id,
            remoteId: remoteId,
            courseId: courseId,
            roomName: roomName,
            dayOfWeek: dayOfWeek,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            weekType: weekType,
            updatedAt: updatedAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            required String courseId,
            Value<String> roomName = const Value.absent(),
            required int dayOfWeek,
            required int startHour,
            required int startMinute,
            required int endHour,
            required int endMinute,
            Value<String> weekType = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarCoursesCompanion.insert(
            id: id,
            remoteId: remoteId,
            courseId: courseId,
            roomName: roomName,
            dayOfWeek: dayOfWeek,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            weekType: weekType,
            updatedAt: updatedAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CalendarCoursesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalendarCoursesTable,
    CalendarCourseEntity,
    $$CalendarCoursesTableFilterComposer,
    $$CalendarCoursesTableOrderingComposer,
    $$CalendarCoursesTableAnnotationComposer,
    $$CalendarCoursesTableCreateCompanionBuilder,
    $$CalendarCoursesTableUpdateCompanionBuilder,
    (
      CalendarCourseEntity,
      BaseReferences<_$AppDatabase, $CalendarCoursesTable, CalendarCourseEntity>
    ),
    CalendarCourseEntity,
    PrefetchHooks Function()>;
typedef $$PendingOperationsTableCreateCompanionBuilder
    = PendingOperationsCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String operationType,
  Value<String?> data,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});
typedef $$PendingOperationsTableUpdateCompanionBuilder
    = PendingOperationsCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operationType,
  Value<String?> data,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationType => $composableBuilder(
      column: $table.operationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);
}

class $$PendingOperationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingOperationsTable,
    PendingOperationEntity,
    $$PendingOperationsTableFilterComposer,
    $$PendingOperationsTableOrderingComposer,
    $$PendingOperationsTableAnnotationComposer,
    $$PendingOperationsTableCreateCompanionBuilder,
    $$PendingOperationsTableUpdateCompanionBuilder,
    (
      PendingOperationEntity,
      BaseReferences<_$AppDatabase, $PendingOperationsTable,
          PendingOperationEntity>
    ),
    PendingOperationEntity,
    PrefetchHooks Function()> {
  $$PendingOperationsTableTableManager(
      _$AppDatabase db, $PendingOperationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operationType = const Value.absent(),
            Value<String?> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingOperationsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            data: data,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String operationType,
            Value<String?> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingOperationsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            data: data,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingOperationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingOperationsTable,
    PendingOperationEntity,
    $$PendingOperationsTableFilterComposer,
    $$PendingOperationsTableOrderingComposer,
    $$PendingOperationsTableAnnotationComposer,
    $$PendingOperationsTableCreateCompanionBuilder,
    $$PendingOperationsTableUpdateCompanionBuilder,
    (
      PendingOperationEntity,
      BaseReferences<_$AppDatabase, $PendingOperationsTable,
          PendingOperationEntity>
    ),
    PendingOperationEntity,
    PrefetchHooks Function()>;
typedef $$DailyChecksTableCreateCompanionBuilder = DailyChecksCompanion
    Function({
  required String id,
  required DateTime date,
  required String supplyId,
  required String courseId,
  Value<bool> isChecked,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$DailyChecksTableUpdateCompanionBuilder = DailyChecksCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String> supplyId,
  Value<String> courseId,
  Value<bool> isChecked,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DailyChecksTableFilterComposer
    extends Composer<_$AppDatabase, $DailyChecksTable> {
  $$DailyChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplyId => $composableBuilder(
      column: $table.supplyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DailyChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyChecksTable> {
  $$DailyChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplyId => $composableBuilder(
      column: $table.supplyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyChecksTable> {
  $$DailyChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get supplyId =>
      $composableBuilder(column: $table.supplyId, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyChecksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyChecksTable,
    DailyCheckEntity,
    $$DailyChecksTableFilterComposer,
    $$DailyChecksTableOrderingComposer,
    $$DailyChecksTableAnnotationComposer,
    $$DailyChecksTableCreateCompanionBuilder,
    $$DailyChecksTableUpdateCompanionBuilder,
    (
      DailyCheckEntity,
      BaseReferences<_$AppDatabase, $DailyChecksTable, DailyCheckEntity>
    ),
    DailyCheckEntity,
    PrefetchHooks Function()> {
  $$DailyChecksTableTableManager(_$AppDatabase db, $DailyChecksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> supplyId = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyChecksCompanion(
            id: id,
            date: date,
            supplyId: supplyId,
            courseId: courseId,
            isChecked: isChecked,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required String supplyId,
            required String courseId,
            Value<bool> isChecked = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyChecksCompanion.insert(
            id: id,
            date: date,
            supplyId: supplyId,
            courseId: courseId,
            isChecked: isChecked,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyChecksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyChecksTable,
    DailyCheckEntity,
    $$DailyChecksTableFilterComposer,
    $$DailyChecksTableOrderingComposer,
    $$DailyChecksTableAnnotationComposer,
    $$DailyChecksTableCreateCompanionBuilder,
    $$DailyChecksTableUpdateCompanionBuilder,
    (
      DailyCheckEntity,
      BaseReferences<_$AppDatabase, $DailyChecksTable, DailyCheckEntity>
    ),
    DailyCheckEntity,
    PrefetchHooks Function()>;
typedef $$BagCompletionsTableCreateCompanionBuilder = BagCompletionsCompanion
    Function({
  required String id,
  required DateTime date,
  required DateTime completedAt,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$BagCompletionsTableUpdateCompanionBuilder = BagCompletionsCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<DateTime> completedAt,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BagCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $BagCompletionsTable> {
  $$BagCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BagCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $BagCompletionsTable> {
  $$BagCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BagCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BagCompletionsTable> {
  $$BagCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BagCompletionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BagCompletionsTable,
    BagCompletionEntity,
    $$BagCompletionsTableFilterComposer,
    $$BagCompletionsTableOrderingComposer,
    $$BagCompletionsTableAnnotationComposer,
    $$BagCompletionsTableCreateCompanionBuilder,
    $$BagCompletionsTableUpdateCompanionBuilder,
    (
      BagCompletionEntity,
      BaseReferences<_$AppDatabase, $BagCompletionsTable, BagCompletionEntity>
    ),
    BagCompletionEntity,
    PrefetchHooks Function()> {
  $$BagCompletionsTableTableManager(
      _$AppDatabase db, $BagCompletionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BagCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BagCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BagCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BagCompletionsCompanion(
            id: id,
            date: date,
            completedAt: completedAt,
            deviceId: deviceId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required DateTime completedAt,
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BagCompletionsCompanion.insert(
            id: id,
            date: date,
            completedAt: completedAt,
            deviceId: deviceId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BagCompletionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BagCompletionsTable,
    BagCompletionEntity,
    $$BagCompletionsTableFilterComposer,
    $$BagCompletionsTableOrderingComposer,
    $$BagCompletionsTableAnnotationComposer,
    $$BagCompletionsTableCreateCompanionBuilder,
    $$BagCompletionsTableUpdateCompanionBuilder,
    (
      BagCompletionEntity,
      BaseReferences<_$AppDatabase, $BagCompletionsTable, BagCompletionEntity>
    ),
    BagCompletionEntity,
    PrefetchHooks Function()>;
typedef $$PremiumStatusTableCreateCompanionBuilder = PremiumStatusCompanion
    Function({
  required String id,
  Value<bool> hasPurchased,
  Value<String?> linkedParentId,
  required DateTime updatedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PremiumStatusTableUpdateCompanionBuilder = PremiumStatusCompanion
    Function({
  Value<String> id,
  Value<bool> hasPurchased,
  Value<String?> linkedParentId,
  Value<DateTime> updatedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PremiumStatusTableFilterComposer
    extends Composer<_$AppDatabase, $PremiumStatusTable> {
  $$PremiumStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPurchased => $composableBuilder(
      column: $table.hasPurchased, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedParentId => $composableBuilder(
      column: $table.linkedParentId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PremiumStatusTableOrderingComposer
    extends Composer<_$AppDatabase, $PremiumStatusTable> {
  $$PremiumStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPurchased => $composableBuilder(
      column: $table.hasPurchased,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedParentId => $composableBuilder(
      column: $table.linkedParentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PremiumStatusTableAnnotationComposer
    extends Composer<_$AppDatabase, $PremiumStatusTable> {
  $$PremiumStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get hasPurchased => $composableBuilder(
      column: $table.hasPurchased, builder: (column) => column);

  GeneratedColumn<String> get linkedParentId => $composableBuilder(
      column: $table.linkedParentId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PremiumStatusTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PremiumStatusTable,
    PremiumStatusEntity,
    $$PremiumStatusTableFilterComposer,
    $$PremiumStatusTableOrderingComposer,
    $$PremiumStatusTableAnnotationComposer,
    $$PremiumStatusTableCreateCompanionBuilder,
    $$PremiumStatusTableUpdateCompanionBuilder,
    (
      PremiumStatusEntity,
      BaseReferences<_$AppDatabase, $PremiumStatusTable, PremiumStatusEntity>
    ),
    PremiumStatusEntity,
    PrefetchHooks Function()> {
  $$PremiumStatusTableTableManager(_$AppDatabase db, $PremiumStatusTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PremiumStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PremiumStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PremiumStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> hasPurchased = const Value.absent(),
            Value<String?> linkedParentId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PremiumStatusCompanion(
            id: id,
            hasPurchased: hasPurchased,
            linkedParentId: linkedParentId,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> hasPurchased = const Value.absent(),
            Value<String?> linkedParentId = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PremiumStatusCompanion.insert(
            id: id,
            hasPurchased: hasPurchased,
            linkedParentId: linkedParentId,
            updatedAt: updatedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PremiumStatusTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PremiumStatusTable,
    PremiumStatusEntity,
    $$PremiumStatusTableFilterComposer,
    $$PremiumStatusTableOrderingComposer,
    $$PremiumStatusTableAnnotationComposer,
    $$PremiumStatusTableCreateCompanionBuilder,
    $$PremiumStatusTableUpdateCompanionBuilder,
    (
      PremiumStatusEntity,
      BaseReferences<_$AppDatabase, $PremiumStatusTable, PremiumStatusEntity>
    ),
    PremiumStatusEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$SuppliesTableTableManager get supplies =>
      $$SuppliesTableTableManager(_db, _db.supplies);
  $$CalendarCoursesTableTableManager get calendarCourses =>
      $$CalendarCoursesTableTableManager(_db, _db.calendarCourses);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$DailyChecksTableTableManager get dailyChecks =>
      $$DailyChecksTableTableManager(_db, _db.dailyChecks);
  $$BagCompletionsTableTableManager get bagCompletions =>
      $$BagCompletionsTableTableManager(_db, _db.bagCompletions);
  $$PremiumStatusTableTableManager get premiumStatus =>
      $$PremiumStatusTableTableManager(_db, _db.premiumStatus);
}
