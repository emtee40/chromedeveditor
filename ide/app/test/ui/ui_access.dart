// Copyright (c) 2013, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library spark.workspace_test;

import 'dart:async';
import 'dart:html';

import 'package:spark_widgets/spark_dialog/spark_dialog.dart';
import 'package:spark_widgets/spark_dialog_button/spark_dialog_button.dart';
import 'package:spark_widgets/spark_menu_button/spark_menu_button.dart';
import 'package:spark_widgets/spark_menu_item/spark_menu_item.dart';
import 'package:spark_widgets/spark_button/spark_button.dart';
import 'package:spark_widgets/spark_modal/spark_modal.dart';
import 'package:spark_widgets/common/spark_widget.dart';
import 'package:unittest/unittest.dart';

import '../../spark_polymer_ui.dart';

class SparkUIAccess {
  static SparkUIAccess _instance;

  factory SparkUIAccess() {
    if (_instance == null) _instance = new SparkUIAccess._internal();
    return _instance;
  }

  SparkUIAccess._internal();

  SparkPolymerUI get _ui => document.querySelector('#topUi');
  Element getUIElement(String selectors) => _ui.getShadowDomElement(selectors);
  void _sendMouseEvent(Element element, String eventType) {
    Rectangle<int> bounds = element.getBoundingClientRect();
    element.dispatchEvent(new MouseEvent(eventType,
        clientX: bounds.left.toInt() + bounds.width ~/ 2,
        clientY:bounds.top.toInt() + bounds.height ~/ 2));
  }

  SparkButton get _menuButton => getUIElement("#mainMenu > spark-button");

  SparkMenuButton get menu => getUIElement("#mainMenu");
  void selectMenu() => _menuButton.click();

  MenuItemAccess newProjectMenu =
      new MenuItemAccess("project-new", "newProjectDialog");

  MenuItemAccess gitCloneMenu =
      new MenuItemAccess("git-clone", "gitCloneDialog");

  MenuItemAccess aboutMenu =
      new MenuItemAccess("help-about", "aboutDialog");

  void clickElement(Element element) {
    _sendMouseEvent(element, "mouseover");
    _sendMouseEvent(element, "click");
  }
}

class MenuItemAccess {
  String _menuItemId;
  DialogAccess _dialog = null;

  MenuItemAccess(this._menuItemId, [String _dialogId]) {
    if (_dialogId != null) {
      _dialog = new DialogAccess(_dialogId);
    }
  }

  SparkUIAccess get _sparkAccess => new SparkUIAccess();

  List<SparkMenuItem> get _menuItems => _sparkAccess.menu.querySelectorAll("spark-menu-item");
  SparkMenuItem _getMenuItem(String id) {
      return _menuItems.firstWhere((SparkMenuItem item) =>
          item.attributes["action-id"] == id);
  }

  SparkMenuItem get _menuItem => _menuItems.firstWhere((SparkMenuItem item) =>
      item.attributes["action-id"] == _menuItemId);

  DialogAccess get dialog => _dialog;

  void select() => _sparkAccess.clickElement(_menuItem);
}

class DialogAccess {
  String _id;
  SparkUIAccess get _sparkAccess => new SparkUIAccess();

  DialogAccess(this._id);

  SparkDialog get _dialog => _sparkAccess.getUIElement("#$_id");

  List<SparkDialogButton> get _dialogButtons =>
      _dialog.querySelectorAll("spark-dialog-button");

  SparkWidget _getButtonByTitle(String title) {
    for (SparkWidget button in _dialogButtons) {
      if (button.text.toLowerCase() == title.toLowerCase()) {
        return button;
      }
    }

    throw "Could not find button with title $title";
  }

  SparkWidget _getButtonById(String id) {
    SparkWidget button = _dialog.querySelector("#$id");

    if (button == null) button = _dialog.getShadowDomElement("#$id");

    if (button == null) throw "Could not find button with id id";

    return button;
  }

  String get id => _id;

  SparkModal get modalElement => _dialog.getShadowDomElement("#modal");

  bool get opened => modalElement.opened;

  void clickButtonWithTitle(String title) =>
      _sparkAccess.clickElement(_getButtonByTitle(title));

  void clickButtonWithId(String id) =>
      _sparkAccess.clickElement(_getButtonById(id));
}
