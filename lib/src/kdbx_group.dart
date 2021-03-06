import 'package:kdbx/kdbx.dart';
import 'package:kdbx/src/kdbx_consts.dart';
import 'package:kdbx/src/kdbx_entry.dart';
import 'package:kdbx/src/kdbx_xml.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import 'kdbx_object.dart';

class KdbxGroup extends KdbxObject {
  KdbxGroup.create({@required KdbxGroup parent, @required String name})
      : super.create(
          parent?.file,
          'Group',
          parent,
        ) {
    this.name.set(name);
    icon.set(KdbxIcon.Folder);
    expanded.set(true);
  }

  KdbxGroup.read(KdbxGroup parent, XmlElement node) : super.read(parent, node) {
    node
        .findElements('Group')
        .map((el) => KdbxGroup.read(this, el))
        .forEach(_groups.add);
    node
        .findElements('Entry')
        .map((el) => KdbxEntry.read(this, el))
        .forEach(_entries.add);
  }

  @override
  XmlElement toXml() {
    final el = super.toXml();
    XmlUtils.removeChildrenByName(el, 'Group');
    XmlUtils.removeChildrenByName(el, 'Entry');
    el.children.addAll(groups.map((g) => g.toXml()));
    el.children.addAll(_entries.map((e) => e.toXml()));
    return el;
  }

  /// Returns all groups plus this group itself.
  List<KdbxGroup> getAllGroups() => groups
      .expand((g) => g.getAllGroups())
      .followedBy([this]).toList(growable: false);

  /// Returns all entries of this group and all sub groups.
  List<KdbxEntry> getAllEntries() =>
      getAllGroups().expand((g) => g.entries).toList(growable: false);

  List<KdbxGroup> get groups => List.unmodifiable(_groups);
  final List<KdbxGroup> _groups = [];

  List<KdbxEntry> get entries => List.unmodifiable(_entries);
  final List<KdbxEntry> _entries = [];

  void addEntry(KdbxEntry entry) {
    if (entry.parent != this) {
      throw StateError(
          'Invalid operation. Trying to add entry which is already in another group.');
    }
    _entries.add(entry);
    isDirty = true;
  }

  void addGroup(KdbxGroup group) {
    if (group.parent != this) {
      throw StateError(
          'Invalid operation. Trying to add group which is already in another group.');
    }
    _groups.add(group);
    isDirty = true;
  }

  void internalRemoveGroup(KdbxGroup group) {
    if (!_groups.remove(group)) {
      throw StateError('Unable to remove $group from $this (Not found)');
    }
    isDirty = true;
  }

  void internalRemoveEntry(KdbxEntry entry) {
    if (!_entries.remove(entry)) {
      throw StateError('Unable to remove $entry from $this (Not found)');
    }
    isDirty = true;
  }

  StringNode get name => StringNode(this, 'Name');

//  String get name => text('Name') ?? '';
  BooleanNode get expanded => BooleanNode(this, 'IsExpanded');

  BooleanNode get enableAutoType => BooleanNode(this, 'EnableAutoType');

  BooleanNode get enableSearching => BooleanNode(this, 'EnableSearching');

  @override
  String toString() {
    return 'KdbxGroup{uuid=$uuid,name=${name.get()}}';
  }
}
