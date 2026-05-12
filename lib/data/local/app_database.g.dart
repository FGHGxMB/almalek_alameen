// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemCodeMeta =
      const VerificationMeta('itemCode');
  @override
  late final GeneratedColumn<String> itemCode = GeneratedColumn<String>(
      'item_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupCodeMeta =
      const VerificationMeta('groupCode');
  @override
  late final GeneratedColumn<String> groupCode = GeneratedColumn<String>(
      'group_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultUnitMeta =
      const VerificationMeta('defaultUnit');
  @override
  late final GeneratedColumn<String> defaultUnit = GeneratedColumn<String>(
      'default_unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  static const VerificationMeta _tabNameMeta =
      const VerificationMeta('tabName');
  @override
  late final GeneratedColumn<String> tabName = GeneratedColumn<String>(
      'tab_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _columnIndexMeta =
      const VerificationMeta('columnIndex');
  @override
  late final GeneratedColumn<int> columnIndex = GeneratedColumn<int>(
      'column_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rowIndexMeta =
      const VerificationMeta('rowIndex');
  @override
  late final GeneratedColumn<int> rowIndex = GeneratedColumn<int>(
      'row_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unit1Meta = const VerificationMeta('unit1');
  @override
  late final GeneratedColumn<String> unit1 = GeneratedColumn<String>(
      'unit1', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcode1Meta =
      const VerificationMeta('barcode1');
  @override
  late final GeneratedColumn<String> barcode1 = GeneratedColumn<String>(
      'barcode1', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shopPrice1Meta =
      const VerificationMeta('shopPrice1');
  @override
  late final GeneratedColumn<double> shopPrice1 = GeneratedColumn<double>(
      'shop_price1', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _consumerPrice1Meta =
      const VerificationMeta('consumerPrice1');
  @override
  late final GeneratedColumn<double> consumerPrice1 = GeneratedColumn<double>(
      'consumer_price1', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unit2Meta = const VerificationMeta('unit2');
  @override
  late final GeneratedColumn<String> unit2 = GeneratedColumn<String>(
      'unit2', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcode2Meta =
      const VerificationMeta('barcode2');
  @override
  late final GeneratedColumn<String> barcode2 = GeneratedColumn<String>(
      'barcode2', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shopPrice2Meta =
      const VerificationMeta('shopPrice2');
  @override
  late final GeneratedColumn<double> shopPrice2 = GeneratedColumn<double>(
      'shop_price2', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _consumerPrice2Meta =
      const VerificationMeta('consumerPrice2');
  @override
  late final GeneratedColumn<double> consumerPrice2 = GeneratedColumn<double>(
      'consumer_price2', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unit3Meta = const VerificationMeta('unit3');
  @override
  late final GeneratedColumn<String> unit3 = GeneratedColumn<String>(
      'unit3', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcode3Meta =
      const VerificationMeta('barcode3');
  @override
  late final GeneratedColumn<String> barcode3 = GeneratedColumn<String>(
      'barcode3', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shopPrice3Meta =
      const VerificationMeta('shopPrice3');
  @override
  late final GeneratedColumn<double> shopPrice3 = GeneratedColumn<double>(
      'shop_price3', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _consumerPrice3Meta =
      const VerificationMeta('consumerPrice3');
  @override
  late final GeneratedColumn<double> consumerPrice3 = GeneratedColumn<double>(
      'consumer_price3', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _minPrice1Meta =
      const VerificationMeta('minPrice1');
  @override
  late final GeneratedColumn<double> minPrice1 = GeneratedColumn<double>(
      'min_price1', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _minPrice2Meta =
      const VerificationMeta('minPrice2');
  @override
  late final GeneratedColumn<double> minPrice2 = GeneratedColumn<double>(
      'min_price2', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _minPrice3Meta =
      const VerificationMeta('minPrice3');
  @override
  late final GeneratedColumn<double> minPrice3 = GeneratedColumn<double>(
      'min_price3', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _costPrice1Meta =
      const VerificationMeta('costPrice1');
  @override
  late final GeneratedColumn<double> costPrice1 = GeneratedColumn<double>(
      'cost_price1', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _costPrice2Meta =
      const VerificationMeta('costPrice2');
  @override
  late final GeneratedColumn<double> costPrice2 = GeneratedColumn<double>(
      'cost_price2', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _costPrice3Meta =
      const VerificationMeta('costPrice3');
  @override
  late final GeneratedColumn<double> costPrice3 = GeneratedColumn<double>(
      'cost_price3', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currency1Meta =
      const VerificationMeta('currency1');
  @override
  late final GeneratedColumn<String> currency1 = GeneratedColumn<String>(
      'currency1', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _currency2Meta =
      const VerificationMeta('currency2');
  @override
  late final GeneratedColumn<String> currency2 = GeneratedColumn<String>(
      'currency2', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _currency3Meta =
      const VerificationMeta('currency3');
  @override
  late final GeneratedColumn<String> currency3 = GeneratedColumn<String>(
      'currency3', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemCode,
        itemName,
        groupCode,
        currencyCode,
        defaultUnit,
        isActive,
        tabName,
        columnIndex,
        rowIndex,
        unit1,
        barcode1,
        shopPrice1,
        consumerPrice1,
        unit2,
        barcode2,
        shopPrice2,
        consumerPrice2,
        unit3,
        barcode3,
        shopPrice3,
        consumerPrice3,
        minPrice1,
        minPrice2,
        minPrice3,
        costPrice1,
        costPrice2,
        costPrice3,
        currency1,
        currency2,
        currency3
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products_table';
  @override
  VerificationContext validateIntegrity(Insertable<ProductsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_code')) {
      context.handle(_itemCodeMeta,
          itemCode.isAcceptableOrUnknown(data['item_code']!, _itemCodeMeta));
    } else if (isInserting) {
      context.missing(_itemCodeMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('group_code')) {
      context.handle(_groupCodeMeta,
          groupCode.isAcceptableOrUnknown(data['group_code']!, _groupCodeMeta));
    } else if (isInserting) {
      context.missing(_groupCodeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('default_unit')) {
      context.handle(
          _defaultUnitMeta,
          defaultUnit.isAcceptableOrUnknown(
              data['default_unit']!, _defaultUnitMeta));
    } else if (isInserting) {
      context.missing(_defaultUnitMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('tab_name')) {
      context.handle(_tabNameMeta,
          tabName.isAcceptableOrUnknown(data['tab_name']!, _tabNameMeta));
    } else if (isInserting) {
      context.missing(_tabNameMeta);
    }
    if (data.containsKey('column_index')) {
      context.handle(
          _columnIndexMeta,
          columnIndex.isAcceptableOrUnknown(
              data['column_index']!, _columnIndexMeta));
    } else if (isInserting) {
      context.missing(_columnIndexMeta);
    }
    if (data.containsKey('row_index')) {
      context.handle(_rowIndexMeta,
          rowIndex.isAcceptableOrUnknown(data['row_index']!, _rowIndexMeta));
    } else if (isInserting) {
      context.missing(_rowIndexMeta);
    }
    if (data.containsKey('unit1')) {
      context.handle(
          _unit1Meta, unit1.isAcceptableOrUnknown(data['unit1']!, _unit1Meta));
    } else if (isInserting) {
      context.missing(_unit1Meta);
    }
    if (data.containsKey('barcode1')) {
      context.handle(_barcode1Meta,
          barcode1.isAcceptableOrUnknown(data['barcode1']!, _barcode1Meta));
    } else if (isInserting) {
      context.missing(_barcode1Meta);
    }
    if (data.containsKey('shop_price1')) {
      context.handle(
          _shopPrice1Meta,
          shopPrice1.isAcceptableOrUnknown(
              data['shop_price1']!, _shopPrice1Meta));
    } else if (isInserting) {
      context.missing(_shopPrice1Meta);
    }
    if (data.containsKey('consumer_price1')) {
      context.handle(
          _consumerPrice1Meta,
          consumerPrice1.isAcceptableOrUnknown(
              data['consumer_price1']!, _consumerPrice1Meta));
    } else if (isInserting) {
      context.missing(_consumerPrice1Meta);
    }
    if (data.containsKey('unit2')) {
      context.handle(
          _unit2Meta, unit2.isAcceptableOrUnknown(data['unit2']!, _unit2Meta));
    } else if (isInserting) {
      context.missing(_unit2Meta);
    }
    if (data.containsKey('barcode2')) {
      context.handle(_barcode2Meta,
          barcode2.isAcceptableOrUnknown(data['barcode2']!, _barcode2Meta));
    } else if (isInserting) {
      context.missing(_barcode2Meta);
    }
    if (data.containsKey('shop_price2')) {
      context.handle(
          _shopPrice2Meta,
          shopPrice2.isAcceptableOrUnknown(
              data['shop_price2']!, _shopPrice2Meta));
    } else if (isInserting) {
      context.missing(_shopPrice2Meta);
    }
    if (data.containsKey('consumer_price2')) {
      context.handle(
          _consumerPrice2Meta,
          consumerPrice2.isAcceptableOrUnknown(
              data['consumer_price2']!, _consumerPrice2Meta));
    } else if (isInserting) {
      context.missing(_consumerPrice2Meta);
    }
    if (data.containsKey('unit3')) {
      context.handle(
          _unit3Meta, unit3.isAcceptableOrUnknown(data['unit3']!, _unit3Meta));
    } else if (isInserting) {
      context.missing(_unit3Meta);
    }
    if (data.containsKey('barcode3')) {
      context.handle(_barcode3Meta,
          barcode3.isAcceptableOrUnknown(data['barcode3']!, _barcode3Meta));
    } else if (isInserting) {
      context.missing(_barcode3Meta);
    }
    if (data.containsKey('shop_price3')) {
      context.handle(
          _shopPrice3Meta,
          shopPrice3.isAcceptableOrUnknown(
              data['shop_price3']!, _shopPrice3Meta));
    } else if (isInserting) {
      context.missing(_shopPrice3Meta);
    }
    if (data.containsKey('consumer_price3')) {
      context.handle(
          _consumerPrice3Meta,
          consumerPrice3.isAcceptableOrUnknown(
              data['consumer_price3']!, _consumerPrice3Meta));
    } else if (isInserting) {
      context.missing(_consumerPrice3Meta);
    }
    if (data.containsKey('min_price1')) {
      context.handle(_minPrice1Meta,
          minPrice1.isAcceptableOrUnknown(data['min_price1']!, _minPrice1Meta));
    }
    if (data.containsKey('min_price2')) {
      context.handle(_minPrice2Meta,
          minPrice2.isAcceptableOrUnknown(data['min_price2']!, _minPrice2Meta));
    }
    if (data.containsKey('min_price3')) {
      context.handle(_minPrice3Meta,
          minPrice3.isAcceptableOrUnknown(data['min_price3']!, _minPrice3Meta));
    }
    if (data.containsKey('cost_price1')) {
      context.handle(
          _costPrice1Meta,
          costPrice1.isAcceptableOrUnknown(
              data['cost_price1']!, _costPrice1Meta));
    }
    if (data.containsKey('cost_price2')) {
      context.handle(
          _costPrice2Meta,
          costPrice2.isAcceptableOrUnknown(
              data['cost_price2']!, _costPrice2Meta));
    }
    if (data.containsKey('cost_price3')) {
      context.handle(
          _costPrice3Meta,
          costPrice3.isAcceptableOrUnknown(
              data['cost_price3']!, _costPrice3Meta));
    }
    if (data.containsKey('currency1')) {
      context.handle(_currency1Meta,
          currency1.isAcceptableOrUnknown(data['currency1']!, _currency1Meta));
    }
    if (data.containsKey('currency2')) {
      context.handle(_currency2Meta,
          currency2.isAcceptableOrUnknown(data['currency2']!, _currency2Meta));
    }
    if (data.containsKey('currency3')) {
      context.handle(_currency3Meta,
          currency3.isAcceptableOrUnknown(data['currency3']!, _currency3Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_code'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      groupCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_code'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      defaultUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_unit'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      tabName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tab_name'])!,
      columnIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}column_index'])!,
      rowIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}row_index'])!,
      unit1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit1'])!,
      barcode1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode1'])!,
      shopPrice1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shop_price1'])!,
      consumerPrice1: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}consumer_price1'])!,
      unit2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit2'])!,
      barcode2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode2'])!,
      shopPrice2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shop_price2'])!,
      consumerPrice2: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}consumer_price2'])!,
      unit3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit3'])!,
      barcode3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode3'])!,
      shopPrice3: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shop_price3'])!,
      consumerPrice3: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}consumer_price3'])!,
      minPrice1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_price1'])!,
      minPrice2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_price2'])!,
      minPrice3: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_price3'])!,
      costPrice1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price1'])!,
      costPrice2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price2'])!,
      costPrice3: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price3'])!,
      currency1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency1'])!,
      currency2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency2'])!,
      currency3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency3'])!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductsTableData extends DataClass
    implements Insertable<ProductsTableData> {
  final String id;
  final String itemCode;
  final String itemName;
  final String groupCode;
  final String currencyCode;
  final String defaultUnit;
  final bool isActive;
  final String tabName;
  final int columnIndex;
  final int rowIndex;
  final String unit1;
  final String barcode1;
  final double shopPrice1;
  final double consumerPrice1;
  final String unit2;
  final String barcode2;
  final double shopPrice2;
  final double consumerPrice2;
  final String unit3;
  final String barcode3;
  final double shopPrice3;
  final double consumerPrice3;
  final double minPrice1;
  final double minPrice2;
  final double minPrice3;
  final double costPrice1;
  final double costPrice2;
  final double costPrice3;
  final String currency1;
  final String currency2;
  final String currency3;
  const ProductsTableData(
      {required this.id,
      required this.itemCode,
      required this.itemName,
      required this.groupCode,
      required this.currencyCode,
      required this.defaultUnit,
      required this.isActive,
      required this.tabName,
      required this.columnIndex,
      required this.rowIndex,
      required this.unit1,
      required this.barcode1,
      required this.shopPrice1,
      required this.consumerPrice1,
      required this.unit2,
      required this.barcode2,
      required this.shopPrice2,
      required this.consumerPrice2,
      required this.unit3,
      required this.barcode3,
      required this.shopPrice3,
      required this.consumerPrice3,
      required this.minPrice1,
      required this.minPrice2,
      required this.minPrice3,
      required this.costPrice1,
      required this.costPrice2,
      required this.costPrice3,
      required this.currency1,
      required this.currency2,
      required this.currency3});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_code'] = Variable<String>(itemCode);
    map['item_name'] = Variable<String>(itemName);
    map['group_code'] = Variable<String>(groupCode);
    map['currency_code'] = Variable<String>(currencyCode);
    map['default_unit'] = Variable<String>(defaultUnit);
    map['is_active'] = Variable<bool>(isActive);
    map['tab_name'] = Variable<String>(tabName);
    map['column_index'] = Variable<int>(columnIndex);
    map['row_index'] = Variable<int>(rowIndex);
    map['unit1'] = Variable<String>(unit1);
    map['barcode1'] = Variable<String>(barcode1);
    map['shop_price1'] = Variable<double>(shopPrice1);
    map['consumer_price1'] = Variable<double>(consumerPrice1);
    map['unit2'] = Variable<String>(unit2);
    map['barcode2'] = Variable<String>(barcode2);
    map['shop_price2'] = Variable<double>(shopPrice2);
    map['consumer_price2'] = Variable<double>(consumerPrice2);
    map['unit3'] = Variable<String>(unit3);
    map['barcode3'] = Variable<String>(barcode3);
    map['shop_price3'] = Variable<double>(shopPrice3);
    map['consumer_price3'] = Variable<double>(consumerPrice3);
    map['min_price1'] = Variable<double>(minPrice1);
    map['min_price2'] = Variable<double>(minPrice2);
    map['min_price3'] = Variable<double>(minPrice3);
    map['cost_price1'] = Variable<double>(costPrice1);
    map['cost_price2'] = Variable<double>(costPrice2);
    map['cost_price3'] = Variable<double>(costPrice3);
    map['currency1'] = Variable<String>(currency1);
    map['currency2'] = Variable<String>(currency2);
    map['currency3'] = Variable<String>(currency3);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      itemCode: Value(itemCode),
      itemName: Value(itemName),
      groupCode: Value(groupCode),
      currencyCode: Value(currencyCode),
      defaultUnit: Value(defaultUnit),
      isActive: Value(isActive),
      tabName: Value(tabName),
      columnIndex: Value(columnIndex),
      rowIndex: Value(rowIndex),
      unit1: Value(unit1),
      barcode1: Value(barcode1),
      shopPrice1: Value(shopPrice1),
      consumerPrice1: Value(consumerPrice1),
      unit2: Value(unit2),
      barcode2: Value(barcode2),
      shopPrice2: Value(shopPrice2),
      consumerPrice2: Value(consumerPrice2),
      unit3: Value(unit3),
      barcode3: Value(barcode3),
      shopPrice3: Value(shopPrice3),
      consumerPrice3: Value(consumerPrice3),
      minPrice1: Value(minPrice1),
      minPrice2: Value(minPrice2),
      minPrice3: Value(minPrice3),
      costPrice1: Value(costPrice1),
      costPrice2: Value(costPrice2),
      costPrice3: Value(costPrice3),
      currency1: Value(currency1),
      currency2: Value(currency2),
      currency3: Value(currency3),
    );
  }

  factory ProductsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductsTableData(
      id: serializer.fromJson<String>(json['id']),
      itemCode: serializer.fromJson<String>(json['itemCode']),
      itemName: serializer.fromJson<String>(json['itemName']),
      groupCode: serializer.fromJson<String>(json['groupCode']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      defaultUnit: serializer.fromJson<String>(json['defaultUnit']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      tabName: serializer.fromJson<String>(json['tabName']),
      columnIndex: serializer.fromJson<int>(json['columnIndex']),
      rowIndex: serializer.fromJson<int>(json['rowIndex']),
      unit1: serializer.fromJson<String>(json['unit1']),
      barcode1: serializer.fromJson<String>(json['barcode1']),
      shopPrice1: serializer.fromJson<double>(json['shopPrice1']),
      consumerPrice1: serializer.fromJson<double>(json['consumerPrice1']),
      unit2: serializer.fromJson<String>(json['unit2']),
      barcode2: serializer.fromJson<String>(json['barcode2']),
      shopPrice2: serializer.fromJson<double>(json['shopPrice2']),
      consumerPrice2: serializer.fromJson<double>(json['consumerPrice2']),
      unit3: serializer.fromJson<String>(json['unit3']),
      barcode3: serializer.fromJson<String>(json['barcode3']),
      shopPrice3: serializer.fromJson<double>(json['shopPrice3']),
      consumerPrice3: serializer.fromJson<double>(json['consumerPrice3']),
      minPrice1: serializer.fromJson<double>(json['minPrice1']),
      minPrice2: serializer.fromJson<double>(json['minPrice2']),
      minPrice3: serializer.fromJson<double>(json['minPrice3']),
      costPrice1: serializer.fromJson<double>(json['costPrice1']),
      costPrice2: serializer.fromJson<double>(json['costPrice2']),
      costPrice3: serializer.fromJson<double>(json['costPrice3']),
      currency1: serializer.fromJson<String>(json['currency1']),
      currency2: serializer.fromJson<String>(json['currency2']),
      currency3: serializer.fromJson<String>(json['currency3']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemCode': serializer.toJson<String>(itemCode),
      'itemName': serializer.toJson<String>(itemName),
      'groupCode': serializer.toJson<String>(groupCode),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'defaultUnit': serializer.toJson<String>(defaultUnit),
      'isActive': serializer.toJson<bool>(isActive),
      'tabName': serializer.toJson<String>(tabName),
      'columnIndex': serializer.toJson<int>(columnIndex),
      'rowIndex': serializer.toJson<int>(rowIndex),
      'unit1': serializer.toJson<String>(unit1),
      'barcode1': serializer.toJson<String>(barcode1),
      'shopPrice1': serializer.toJson<double>(shopPrice1),
      'consumerPrice1': serializer.toJson<double>(consumerPrice1),
      'unit2': serializer.toJson<String>(unit2),
      'barcode2': serializer.toJson<String>(barcode2),
      'shopPrice2': serializer.toJson<double>(shopPrice2),
      'consumerPrice2': serializer.toJson<double>(consumerPrice2),
      'unit3': serializer.toJson<String>(unit3),
      'barcode3': serializer.toJson<String>(barcode3),
      'shopPrice3': serializer.toJson<double>(shopPrice3),
      'consumerPrice3': serializer.toJson<double>(consumerPrice3),
      'minPrice1': serializer.toJson<double>(minPrice1),
      'minPrice2': serializer.toJson<double>(minPrice2),
      'minPrice3': serializer.toJson<double>(minPrice3),
      'costPrice1': serializer.toJson<double>(costPrice1),
      'costPrice2': serializer.toJson<double>(costPrice2),
      'costPrice3': serializer.toJson<double>(costPrice3),
      'currency1': serializer.toJson<String>(currency1),
      'currency2': serializer.toJson<String>(currency2),
      'currency3': serializer.toJson<String>(currency3),
    };
  }

  ProductsTableData copyWith(
          {String? id,
          String? itemCode,
          String? itemName,
          String? groupCode,
          String? currencyCode,
          String? defaultUnit,
          bool? isActive,
          String? tabName,
          int? columnIndex,
          int? rowIndex,
          String? unit1,
          String? barcode1,
          double? shopPrice1,
          double? consumerPrice1,
          String? unit2,
          String? barcode2,
          double? shopPrice2,
          double? consumerPrice2,
          String? unit3,
          String? barcode3,
          double? shopPrice3,
          double? consumerPrice3,
          double? minPrice1,
          double? minPrice2,
          double? minPrice3,
          double? costPrice1,
          double? costPrice2,
          double? costPrice3,
          String? currency1,
          String? currency2,
          String? currency3}) =>
      ProductsTableData(
        id: id ?? this.id,
        itemCode: itemCode ?? this.itemCode,
        itemName: itemName ?? this.itemName,
        groupCode: groupCode ?? this.groupCode,
        currencyCode: currencyCode ?? this.currencyCode,
        defaultUnit: defaultUnit ?? this.defaultUnit,
        isActive: isActive ?? this.isActive,
        tabName: tabName ?? this.tabName,
        columnIndex: columnIndex ?? this.columnIndex,
        rowIndex: rowIndex ?? this.rowIndex,
        unit1: unit1 ?? this.unit1,
        barcode1: barcode1 ?? this.barcode1,
        shopPrice1: shopPrice1 ?? this.shopPrice1,
        consumerPrice1: consumerPrice1 ?? this.consumerPrice1,
        unit2: unit2 ?? this.unit2,
        barcode2: barcode2 ?? this.barcode2,
        shopPrice2: shopPrice2 ?? this.shopPrice2,
        consumerPrice2: consumerPrice2 ?? this.consumerPrice2,
        unit3: unit3 ?? this.unit3,
        barcode3: barcode3 ?? this.barcode3,
        shopPrice3: shopPrice3 ?? this.shopPrice3,
        consumerPrice3: consumerPrice3 ?? this.consumerPrice3,
        minPrice1: minPrice1 ?? this.minPrice1,
        minPrice2: minPrice2 ?? this.minPrice2,
        minPrice3: minPrice3 ?? this.minPrice3,
        costPrice1: costPrice1 ?? this.costPrice1,
        costPrice2: costPrice2 ?? this.costPrice2,
        costPrice3: costPrice3 ?? this.costPrice3,
        currency1: currency1 ?? this.currency1,
        currency2: currency2 ?? this.currency2,
        currency3: currency3 ?? this.currency3,
      );
  ProductsTableData copyWithCompanion(ProductsTableCompanion data) {
    return ProductsTableData(
      id: data.id.present ? data.id.value : this.id,
      itemCode: data.itemCode.present ? data.itemCode.value : this.itemCode,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      groupCode: data.groupCode.present ? data.groupCode.value : this.groupCode,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      defaultUnit:
          data.defaultUnit.present ? data.defaultUnit.value : this.defaultUnit,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      tabName: data.tabName.present ? data.tabName.value : this.tabName,
      columnIndex:
          data.columnIndex.present ? data.columnIndex.value : this.columnIndex,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      unit1: data.unit1.present ? data.unit1.value : this.unit1,
      barcode1: data.barcode1.present ? data.barcode1.value : this.barcode1,
      shopPrice1:
          data.shopPrice1.present ? data.shopPrice1.value : this.shopPrice1,
      consumerPrice1: data.consumerPrice1.present
          ? data.consumerPrice1.value
          : this.consumerPrice1,
      unit2: data.unit2.present ? data.unit2.value : this.unit2,
      barcode2: data.barcode2.present ? data.barcode2.value : this.barcode2,
      shopPrice2:
          data.shopPrice2.present ? data.shopPrice2.value : this.shopPrice2,
      consumerPrice2: data.consumerPrice2.present
          ? data.consumerPrice2.value
          : this.consumerPrice2,
      unit3: data.unit3.present ? data.unit3.value : this.unit3,
      barcode3: data.barcode3.present ? data.barcode3.value : this.barcode3,
      shopPrice3:
          data.shopPrice3.present ? data.shopPrice3.value : this.shopPrice3,
      consumerPrice3: data.consumerPrice3.present
          ? data.consumerPrice3.value
          : this.consumerPrice3,
      minPrice1: data.minPrice1.present ? data.minPrice1.value : this.minPrice1,
      minPrice2: data.minPrice2.present ? data.minPrice2.value : this.minPrice2,
      minPrice3: data.minPrice3.present ? data.minPrice3.value : this.minPrice3,
      costPrice1:
          data.costPrice1.present ? data.costPrice1.value : this.costPrice1,
      costPrice2:
          data.costPrice2.present ? data.costPrice2.value : this.costPrice2,
      costPrice3:
          data.costPrice3.present ? data.costPrice3.value : this.costPrice3,
      currency1: data.currency1.present ? data.currency1.value : this.currency1,
      currency2: data.currency2.present ? data.currency2.value : this.currency2,
      currency3: data.currency3.present ? data.currency3.value : this.currency3,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableData(')
          ..write('id: $id, ')
          ..write('itemCode: $itemCode, ')
          ..write('itemName: $itemName, ')
          ..write('groupCode: $groupCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('isActive: $isActive, ')
          ..write('tabName: $tabName, ')
          ..write('columnIndex: $columnIndex, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('unit1: $unit1, ')
          ..write('barcode1: $barcode1, ')
          ..write('shopPrice1: $shopPrice1, ')
          ..write('consumerPrice1: $consumerPrice1, ')
          ..write('unit2: $unit2, ')
          ..write('barcode2: $barcode2, ')
          ..write('shopPrice2: $shopPrice2, ')
          ..write('consumerPrice2: $consumerPrice2, ')
          ..write('unit3: $unit3, ')
          ..write('barcode3: $barcode3, ')
          ..write('shopPrice3: $shopPrice3, ')
          ..write('consumerPrice3: $consumerPrice3, ')
          ..write('minPrice1: $minPrice1, ')
          ..write('minPrice2: $minPrice2, ')
          ..write('minPrice3: $minPrice3, ')
          ..write('costPrice1: $costPrice1, ')
          ..write('costPrice2: $costPrice2, ')
          ..write('costPrice3: $costPrice3, ')
          ..write('currency1: $currency1, ')
          ..write('currency2: $currency2, ')
          ..write('currency3: $currency3')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        itemCode,
        itemName,
        groupCode,
        currencyCode,
        defaultUnit,
        isActive,
        tabName,
        columnIndex,
        rowIndex,
        unit1,
        barcode1,
        shopPrice1,
        consumerPrice1,
        unit2,
        barcode2,
        shopPrice2,
        consumerPrice2,
        unit3,
        barcode3,
        shopPrice3,
        consumerPrice3,
        minPrice1,
        minPrice2,
        minPrice3,
        costPrice1,
        costPrice2,
        costPrice3,
        currency1,
        currency2,
        currency3
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductsTableData &&
          other.id == this.id &&
          other.itemCode == this.itemCode &&
          other.itemName == this.itemName &&
          other.groupCode == this.groupCode &&
          other.currencyCode == this.currencyCode &&
          other.defaultUnit == this.defaultUnit &&
          other.isActive == this.isActive &&
          other.tabName == this.tabName &&
          other.columnIndex == this.columnIndex &&
          other.rowIndex == this.rowIndex &&
          other.unit1 == this.unit1 &&
          other.barcode1 == this.barcode1 &&
          other.shopPrice1 == this.shopPrice1 &&
          other.consumerPrice1 == this.consumerPrice1 &&
          other.unit2 == this.unit2 &&
          other.barcode2 == this.barcode2 &&
          other.shopPrice2 == this.shopPrice2 &&
          other.consumerPrice2 == this.consumerPrice2 &&
          other.unit3 == this.unit3 &&
          other.barcode3 == this.barcode3 &&
          other.shopPrice3 == this.shopPrice3 &&
          other.consumerPrice3 == this.consumerPrice3 &&
          other.minPrice1 == this.minPrice1 &&
          other.minPrice2 == this.minPrice2 &&
          other.minPrice3 == this.minPrice3 &&
          other.costPrice1 == this.costPrice1 &&
          other.costPrice2 == this.costPrice2 &&
          other.costPrice3 == this.costPrice3 &&
          other.currency1 == this.currency1 &&
          other.currency2 == this.currency2 &&
          other.currency3 == this.currency3);
}

class ProductsTableCompanion extends UpdateCompanion<ProductsTableData> {
  final Value<String> id;
  final Value<String> itemCode;
  final Value<String> itemName;
  final Value<String> groupCode;
  final Value<String> currencyCode;
  final Value<String> defaultUnit;
  final Value<bool> isActive;
  final Value<String> tabName;
  final Value<int> columnIndex;
  final Value<int> rowIndex;
  final Value<String> unit1;
  final Value<String> barcode1;
  final Value<double> shopPrice1;
  final Value<double> consumerPrice1;
  final Value<String> unit2;
  final Value<String> barcode2;
  final Value<double> shopPrice2;
  final Value<double> consumerPrice2;
  final Value<String> unit3;
  final Value<String> barcode3;
  final Value<double> shopPrice3;
  final Value<double> consumerPrice3;
  final Value<double> minPrice1;
  final Value<double> minPrice2;
  final Value<double> minPrice3;
  final Value<double> costPrice1;
  final Value<double> costPrice2;
  final Value<double> costPrice3;
  final Value<String> currency1;
  final Value<String> currency2;
  final Value<String> currency3;
  final Value<int> rowid;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.itemName = const Value.absent(),
    this.groupCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.defaultUnit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.tabName = const Value.absent(),
    this.columnIndex = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.unit1 = const Value.absent(),
    this.barcode1 = const Value.absent(),
    this.shopPrice1 = const Value.absent(),
    this.consumerPrice1 = const Value.absent(),
    this.unit2 = const Value.absent(),
    this.barcode2 = const Value.absent(),
    this.shopPrice2 = const Value.absent(),
    this.consumerPrice2 = const Value.absent(),
    this.unit3 = const Value.absent(),
    this.barcode3 = const Value.absent(),
    this.shopPrice3 = const Value.absent(),
    this.consumerPrice3 = const Value.absent(),
    this.minPrice1 = const Value.absent(),
    this.minPrice2 = const Value.absent(),
    this.minPrice3 = const Value.absent(),
    this.costPrice1 = const Value.absent(),
    this.costPrice2 = const Value.absent(),
    this.costPrice3 = const Value.absent(),
    this.currency1 = const Value.absent(),
    this.currency2 = const Value.absent(),
    this.currency3 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    required String id,
    required String itemCode,
    required String itemName,
    required String groupCode,
    required String currencyCode,
    required String defaultUnit,
    required bool isActive,
    required String tabName,
    required int columnIndex,
    required int rowIndex,
    required String unit1,
    required String barcode1,
    required double shopPrice1,
    required double consumerPrice1,
    required String unit2,
    required String barcode2,
    required double shopPrice2,
    required double consumerPrice2,
    required String unit3,
    required String barcode3,
    required double shopPrice3,
    required double consumerPrice3,
    this.minPrice1 = const Value.absent(),
    this.minPrice2 = const Value.absent(),
    this.minPrice3 = const Value.absent(),
    this.costPrice1 = const Value.absent(),
    this.costPrice2 = const Value.absent(),
    this.costPrice3 = const Value.absent(),
    this.currency1 = const Value.absent(),
    this.currency2 = const Value.absent(),
    this.currency3 = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemCode = Value(itemCode),
        itemName = Value(itemName),
        groupCode = Value(groupCode),
        currencyCode = Value(currencyCode),
        defaultUnit = Value(defaultUnit),
        isActive = Value(isActive),
        tabName = Value(tabName),
        columnIndex = Value(columnIndex),
        rowIndex = Value(rowIndex),
        unit1 = Value(unit1),
        barcode1 = Value(barcode1),
        shopPrice1 = Value(shopPrice1),
        consumerPrice1 = Value(consumerPrice1),
        unit2 = Value(unit2),
        barcode2 = Value(barcode2),
        shopPrice2 = Value(shopPrice2),
        consumerPrice2 = Value(consumerPrice2),
        unit3 = Value(unit3),
        barcode3 = Value(barcode3),
        shopPrice3 = Value(shopPrice3),
        consumerPrice3 = Value(consumerPrice3);
  static Insertable<ProductsTableData> custom({
    Expression<String>? id,
    Expression<String>? itemCode,
    Expression<String>? itemName,
    Expression<String>? groupCode,
    Expression<String>? currencyCode,
    Expression<String>? defaultUnit,
    Expression<bool>? isActive,
    Expression<String>? tabName,
    Expression<int>? columnIndex,
    Expression<int>? rowIndex,
    Expression<String>? unit1,
    Expression<String>? barcode1,
    Expression<double>? shopPrice1,
    Expression<double>? consumerPrice1,
    Expression<String>? unit2,
    Expression<String>? barcode2,
    Expression<double>? shopPrice2,
    Expression<double>? consumerPrice2,
    Expression<String>? unit3,
    Expression<String>? barcode3,
    Expression<double>? shopPrice3,
    Expression<double>? consumerPrice3,
    Expression<double>? minPrice1,
    Expression<double>? minPrice2,
    Expression<double>? minPrice3,
    Expression<double>? costPrice1,
    Expression<double>? costPrice2,
    Expression<double>? costPrice3,
    Expression<String>? currency1,
    Expression<String>? currency2,
    Expression<String>? currency3,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemCode != null) 'item_code': itemCode,
      if (itemName != null) 'item_name': itemName,
      if (groupCode != null) 'group_code': groupCode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (defaultUnit != null) 'default_unit': defaultUnit,
      if (isActive != null) 'is_active': isActive,
      if (tabName != null) 'tab_name': tabName,
      if (columnIndex != null) 'column_index': columnIndex,
      if (rowIndex != null) 'row_index': rowIndex,
      if (unit1 != null) 'unit1': unit1,
      if (barcode1 != null) 'barcode1': barcode1,
      if (shopPrice1 != null) 'shop_price1': shopPrice1,
      if (consumerPrice1 != null) 'consumer_price1': consumerPrice1,
      if (unit2 != null) 'unit2': unit2,
      if (barcode2 != null) 'barcode2': barcode2,
      if (shopPrice2 != null) 'shop_price2': shopPrice2,
      if (consumerPrice2 != null) 'consumer_price2': consumerPrice2,
      if (unit3 != null) 'unit3': unit3,
      if (barcode3 != null) 'barcode3': barcode3,
      if (shopPrice3 != null) 'shop_price3': shopPrice3,
      if (consumerPrice3 != null) 'consumer_price3': consumerPrice3,
      if (minPrice1 != null) 'min_price1': minPrice1,
      if (minPrice2 != null) 'min_price2': minPrice2,
      if (minPrice3 != null) 'min_price3': minPrice3,
      if (costPrice1 != null) 'cost_price1': costPrice1,
      if (costPrice2 != null) 'cost_price2': costPrice2,
      if (costPrice3 != null) 'cost_price3': costPrice3,
      if (currency1 != null) 'currency1': currency1,
      if (currency2 != null) 'currency2': currency2,
      if (currency3 != null) 'currency3': currency3,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemCode,
      Value<String>? itemName,
      Value<String>? groupCode,
      Value<String>? currencyCode,
      Value<String>? defaultUnit,
      Value<bool>? isActive,
      Value<String>? tabName,
      Value<int>? columnIndex,
      Value<int>? rowIndex,
      Value<String>? unit1,
      Value<String>? barcode1,
      Value<double>? shopPrice1,
      Value<double>? consumerPrice1,
      Value<String>? unit2,
      Value<String>? barcode2,
      Value<double>? shopPrice2,
      Value<double>? consumerPrice2,
      Value<String>? unit3,
      Value<String>? barcode3,
      Value<double>? shopPrice3,
      Value<double>? consumerPrice3,
      Value<double>? minPrice1,
      Value<double>? minPrice2,
      Value<double>? minPrice3,
      Value<double>? costPrice1,
      Value<double>? costPrice2,
      Value<double>? costPrice3,
      Value<String>? currency1,
      Value<String>? currency2,
      Value<String>? currency3,
      Value<int>? rowid}) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      groupCode: groupCode ?? this.groupCode,
      currencyCode: currencyCode ?? this.currencyCode,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      isActive: isActive ?? this.isActive,
      tabName: tabName ?? this.tabName,
      columnIndex: columnIndex ?? this.columnIndex,
      rowIndex: rowIndex ?? this.rowIndex,
      unit1: unit1 ?? this.unit1,
      barcode1: barcode1 ?? this.barcode1,
      shopPrice1: shopPrice1 ?? this.shopPrice1,
      consumerPrice1: consumerPrice1 ?? this.consumerPrice1,
      unit2: unit2 ?? this.unit2,
      barcode2: barcode2 ?? this.barcode2,
      shopPrice2: shopPrice2 ?? this.shopPrice2,
      consumerPrice2: consumerPrice2 ?? this.consumerPrice2,
      unit3: unit3 ?? this.unit3,
      barcode3: barcode3 ?? this.barcode3,
      shopPrice3: shopPrice3 ?? this.shopPrice3,
      consumerPrice3: consumerPrice3 ?? this.consumerPrice3,
      minPrice1: minPrice1 ?? this.minPrice1,
      minPrice2: minPrice2 ?? this.minPrice2,
      minPrice3: minPrice3 ?? this.minPrice3,
      costPrice1: costPrice1 ?? this.costPrice1,
      costPrice2: costPrice2 ?? this.costPrice2,
      costPrice3: costPrice3 ?? this.costPrice3,
      currency1: currency1 ?? this.currency1,
      currency2: currency2 ?? this.currency2,
      currency3: currency3 ?? this.currency3,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemCode.present) {
      map['item_code'] = Variable<String>(itemCode.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (groupCode.present) {
      map['group_code'] = Variable<String>(groupCode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (defaultUnit.present) {
      map['default_unit'] = Variable<String>(defaultUnit.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (tabName.present) {
      map['tab_name'] = Variable<String>(tabName.value);
    }
    if (columnIndex.present) {
      map['column_index'] = Variable<int>(columnIndex.value);
    }
    if (rowIndex.present) {
      map['row_index'] = Variable<int>(rowIndex.value);
    }
    if (unit1.present) {
      map['unit1'] = Variable<String>(unit1.value);
    }
    if (barcode1.present) {
      map['barcode1'] = Variable<String>(barcode1.value);
    }
    if (shopPrice1.present) {
      map['shop_price1'] = Variable<double>(shopPrice1.value);
    }
    if (consumerPrice1.present) {
      map['consumer_price1'] = Variable<double>(consumerPrice1.value);
    }
    if (unit2.present) {
      map['unit2'] = Variable<String>(unit2.value);
    }
    if (barcode2.present) {
      map['barcode2'] = Variable<String>(barcode2.value);
    }
    if (shopPrice2.present) {
      map['shop_price2'] = Variable<double>(shopPrice2.value);
    }
    if (consumerPrice2.present) {
      map['consumer_price2'] = Variable<double>(consumerPrice2.value);
    }
    if (unit3.present) {
      map['unit3'] = Variable<String>(unit3.value);
    }
    if (barcode3.present) {
      map['barcode3'] = Variable<String>(barcode3.value);
    }
    if (shopPrice3.present) {
      map['shop_price3'] = Variable<double>(shopPrice3.value);
    }
    if (consumerPrice3.present) {
      map['consumer_price3'] = Variable<double>(consumerPrice3.value);
    }
    if (minPrice1.present) {
      map['min_price1'] = Variable<double>(minPrice1.value);
    }
    if (minPrice2.present) {
      map['min_price2'] = Variable<double>(minPrice2.value);
    }
    if (minPrice3.present) {
      map['min_price3'] = Variable<double>(minPrice3.value);
    }
    if (costPrice1.present) {
      map['cost_price1'] = Variable<double>(costPrice1.value);
    }
    if (costPrice2.present) {
      map['cost_price2'] = Variable<double>(costPrice2.value);
    }
    if (costPrice3.present) {
      map['cost_price3'] = Variable<double>(costPrice3.value);
    }
    if (currency1.present) {
      map['currency1'] = Variable<String>(currency1.value);
    }
    if (currency2.present) {
      map['currency2'] = Variable<String>(currency2.value);
    }
    if (currency3.present) {
      map['currency3'] = Variable<String>(currency3.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('itemCode: $itemCode, ')
          ..write('itemName: $itemName, ')
          ..write('groupCode: $groupCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('isActive: $isActive, ')
          ..write('tabName: $tabName, ')
          ..write('columnIndex: $columnIndex, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('unit1: $unit1, ')
          ..write('barcode1: $barcode1, ')
          ..write('shopPrice1: $shopPrice1, ')
          ..write('consumerPrice1: $consumerPrice1, ')
          ..write('unit2: $unit2, ')
          ..write('barcode2: $barcode2, ')
          ..write('shopPrice2: $shopPrice2, ')
          ..write('consumerPrice2: $consumerPrice2, ')
          ..write('unit3: $unit3, ')
          ..write('barcode3: $barcode3, ')
          ..write('shopPrice3: $shopPrice3, ')
          ..write('consumerPrice3: $consumerPrice3, ')
          ..write('minPrice1: $minPrice1, ')
          ..write('minPrice2: $minPrice2, ')
          ..write('minPrice3: $minPrice3, ')
          ..write('costPrice1: $costPrice1, ')
          ..write('costPrice2: $costPrice2, ')
          ..write('costPrice3: $costPrice3, ')
          ..write('currency1: $currency1, ')
          ..write('currency2: $currency2, ')
          ..write('currency3: $currency3, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [productsTable];
}

typedef $$ProductsTableTableCreateCompanionBuilder = ProductsTableCompanion
    Function({
  required String id,
  required String itemCode,
  required String itemName,
  required String groupCode,
  required String currencyCode,
  required String defaultUnit,
  required bool isActive,
  required String tabName,
  required int columnIndex,
  required int rowIndex,
  required String unit1,
  required String barcode1,
  required double shopPrice1,
  required double consumerPrice1,
  required String unit2,
  required String barcode2,
  required double shopPrice2,
  required double consumerPrice2,
  required String unit3,
  required String barcode3,
  required double shopPrice3,
  required double consumerPrice3,
  Value<double> minPrice1,
  Value<double> minPrice2,
  Value<double> minPrice3,
  Value<double> costPrice1,
  Value<double> costPrice2,
  Value<double> costPrice3,
  Value<String> currency1,
  Value<String> currency2,
  Value<String> currency3,
  Value<int> rowid,
});
typedef $$ProductsTableTableUpdateCompanionBuilder = ProductsTableCompanion
    Function({
  Value<String> id,
  Value<String> itemCode,
  Value<String> itemName,
  Value<String> groupCode,
  Value<String> currencyCode,
  Value<String> defaultUnit,
  Value<bool> isActive,
  Value<String> tabName,
  Value<int> columnIndex,
  Value<int> rowIndex,
  Value<String> unit1,
  Value<String> barcode1,
  Value<double> shopPrice1,
  Value<double> consumerPrice1,
  Value<String> unit2,
  Value<String> barcode2,
  Value<double> shopPrice2,
  Value<double> consumerPrice2,
  Value<String> unit3,
  Value<String> barcode3,
  Value<double> shopPrice3,
  Value<double> consumerPrice3,
  Value<double> minPrice1,
  Value<double> minPrice2,
  Value<double> minPrice3,
  Value<double> costPrice1,
  Value<double> costPrice2,
  Value<double> costPrice3,
  Value<String> currency1,
  Value<String> currency2,
  Value<String> currency3,
  Value<int> rowid,
});

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupCode => $composableBuilder(
      column: $table.groupCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultUnit => $composableBuilder(
      column: $table.defaultUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tabName => $composableBuilder(
      column: $table.tabName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get columnIndex => $composableBuilder(
      column: $table.columnIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rowIndex => $composableBuilder(
      column: $table.rowIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit1 => $composableBuilder(
      column: $table.unit1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode1 => $composableBuilder(
      column: $table.barcode1, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shopPrice1 => $composableBuilder(
      column: $table.shopPrice1, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get consumerPrice1 => $composableBuilder(
      column: $table.consumerPrice1,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit2 => $composableBuilder(
      column: $table.unit2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode2 => $composableBuilder(
      column: $table.barcode2, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shopPrice2 => $composableBuilder(
      column: $table.shopPrice2, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get consumerPrice2 => $composableBuilder(
      column: $table.consumerPrice2,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit3 => $composableBuilder(
      column: $table.unit3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode3 => $composableBuilder(
      column: $table.barcode3, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shopPrice3 => $composableBuilder(
      column: $table.shopPrice3, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get consumerPrice3 => $composableBuilder(
      column: $table.consumerPrice3,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minPrice1 => $composableBuilder(
      column: $table.minPrice1, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minPrice2 => $composableBuilder(
      column: $table.minPrice2, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minPrice3 => $composableBuilder(
      column: $table.minPrice3, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice1 => $composableBuilder(
      column: $table.costPrice1, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice2 => $composableBuilder(
      column: $table.costPrice2, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice3 => $composableBuilder(
      column: $table.costPrice3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency1 => $composableBuilder(
      column: $table.currency1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency2 => $composableBuilder(
      column: $table.currency2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency3 => $composableBuilder(
      column: $table.currency3, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupCode => $composableBuilder(
      column: $table.groupCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultUnit => $composableBuilder(
      column: $table.defaultUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tabName => $composableBuilder(
      column: $table.tabName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get columnIndex => $composableBuilder(
      column: $table.columnIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rowIndex => $composableBuilder(
      column: $table.rowIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit1 => $composableBuilder(
      column: $table.unit1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode1 => $composableBuilder(
      column: $table.barcode1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shopPrice1 => $composableBuilder(
      column: $table.shopPrice1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get consumerPrice1 => $composableBuilder(
      column: $table.consumerPrice1,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit2 => $composableBuilder(
      column: $table.unit2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode2 => $composableBuilder(
      column: $table.barcode2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shopPrice2 => $composableBuilder(
      column: $table.shopPrice2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get consumerPrice2 => $composableBuilder(
      column: $table.consumerPrice2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit3 => $composableBuilder(
      column: $table.unit3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode3 => $composableBuilder(
      column: $table.barcode3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shopPrice3 => $composableBuilder(
      column: $table.shopPrice3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get consumerPrice3 => $composableBuilder(
      column: $table.consumerPrice3,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minPrice1 => $composableBuilder(
      column: $table.minPrice1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minPrice2 => $composableBuilder(
      column: $table.minPrice2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minPrice3 => $composableBuilder(
      column: $table.minPrice3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice1 => $composableBuilder(
      column: $table.costPrice1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice2 => $composableBuilder(
      column: $table.costPrice2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice3 => $composableBuilder(
      column: $table.costPrice3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency1 => $composableBuilder(
      column: $table.currency1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency2 => $composableBuilder(
      column: $table.currency2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency3 => $composableBuilder(
      column: $table.currency3, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemCode =>
      $composableBuilder(column: $table.itemCode, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get groupCode =>
      $composableBuilder(column: $table.groupCode, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get defaultUnit => $composableBuilder(
      column: $table.defaultUnit, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get tabName =>
      $composableBuilder(column: $table.tabName, builder: (column) => column);

  GeneratedColumn<int> get columnIndex => $composableBuilder(
      column: $table.columnIndex, builder: (column) => column);

  GeneratedColumn<int> get rowIndex =>
      $composableBuilder(column: $table.rowIndex, builder: (column) => column);

  GeneratedColumn<String> get unit1 =>
      $composableBuilder(column: $table.unit1, builder: (column) => column);

  GeneratedColumn<String> get barcode1 =>
      $composableBuilder(column: $table.barcode1, builder: (column) => column);

  GeneratedColumn<double> get shopPrice1 => $composableBuilder(
      column: $table.shopPrice1, builder: (column) => column);

  GeneratedColumn<double> get consumerPrice1 => $composableBuilder(
      column: $table.consumerPrice1, builder: (column) => column);

  GeneratedColumn<String> get unit2 =>
      $composableBuilder(column: $table.unit2, builder: (column) => column);

  GeneratedColumn<String> get barcode2 =>
      $composableBuilder(column: $table.barcode2, builder: (column) => column);

  GeneratedColumn<double> get shopPrice2 => $composableBuilder(
      column: $table.shopPrice2, builder: (column) => column);

  GeneratedColumn<double> get consumerPrice2 => $composableBuilder(
      column: $table.consumerPrice2, builder: (column) => column);

  GeneratedColumn<String> get unit3 =>
      $composableBuilder(column: $table.unit3, builder: (column) => column);

  GeneratedColumn<String> get barcode3 =>
      $composableBuilder(column: $table.barcode3, builder: (column) => column);

  GeneratedColumn<double> get shopPrice3 => $composableBuilder(
      column: $table.shopPrice3, builder: (column) => column);

  GeneratedColumn<double> get consumerPrice3 => $composableBuilder(
      column: $table.consumerPrice3, builder: (column) => column);

  GeneratedColumn<double> get minPrice1 =>
      $composableBuilder(column: $table.minPrice1, builder: (column) => column);

  GeneratedColumn<double> get minPrice2 =>
      $composableBuilder(column: $table.minPrice2, builder: (column) => column);

  GeneratedColumn<double> get minPrice3 =>
      $composableBuilder(column: $table.minPrice3, builder: (column) => column);

  GeneratedColumn<double> get costPrice1 => $composableBuilder(
      column: $table.costPrice1, builder: (column) => column);

  GeneratedColumn<double> get costPrice2 => $composableBuilder(
      column: $table.costPrice2, builder: (column) => column);

  GeneratedColumn<double> get costPrice3 => $composableBuilder(
      column: $table.costPrice3, builder: (column) => column);

  GeneratedColumn<String> get currency1 =>
      $composableBuilder(column: $table.currency1, builder: (column) => column);

  GeneratedColumn<String> get currency2 =>
      $composableBuilder(column: $table.currency2, builder: (column) => column);

  GeneratedColumn<String> get currency3 =>
      $composableBuilder(column: $table.currency3, builder: (column) => column);
}

class $$ProductsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductsTableData,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (
      ProductsTableData,
      BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData>
    ),
    ProductsTableData,
    PrefetchHooks Function()> {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemCode = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<String> groupCode = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String> defaultUnit = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> tabName = const Value.absent(),
            Value<int> columnIndex = const Value.absent(),
            Value<int> rowIndex = const Value.absent(),
            Value<String> unit1 = const Value.absent(),
            Value<String> barcode1 = const Value.absent(),
            Value<double> shopPrice1 = const Value.absent(),
            Value<double> consumerPrice1 = const Value.absent(),
            Value<String> unit2 = const Value.absent(),
            Value<String> barcode2 = const Value.absent(),
            Value<double> shopPrice2 = const Value.absent(),
            Value<double> consumerPrice2 = const Value.absent(),
            Value<String> unit3 = const Value.absent(),
            Value<String> barcode3 = const Value.absent(),
            Value<double> shopPrice3 = const Value.absent(),
            Value<double> consumerPrice3 = const Value.absent(),
            Value<double> minPrice1 = const Value.absent(),
            Value<double> minPrice2 = const Value.absent(),
            Value<double> minPrice3 = const Value.absent(),
            Value<double> costPrice1 = const Value.absent(),
            Value<double> costPrice2 = const Value.absent(),
            Value<double> costPrice3 = const Value.absent(),
            Value<String> currency1 = const Value.absent(),
            Value<String> currency2 = const Value.absent(),
            Value<String> currency3 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsTableCompanion(
            id: id,
            itemCode: itemCode,
            itemName: itemName,
            groupCode: groupCode,
            currencyCode: currencyCode,
            defaultUnit: defaultUnit,
            isActive: isActive,
            tabName: tabName,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            unit1: unit1,
            barcode1: barcode1,
            shopPrice1: shopPrice1,
            consumerPrice1: consumerPrice1,
            unit2: unit2,
            barcode2: barcode2,
            shopPrice2: shopPrice2,
            consumerPrice2: consumerPrice2,
            unit3: unit3,
            barcode3: barcode3,
            shopPrice3: shopPrice3,
            consumerPrice3: consumerPrice3,
            minPrice1: minPrice1,
            minPrice2: minPrice2,
            minPrice3: minPrice3,
            costPrice1: costPrice1,
            costPrice2: costPrice2,
            costPrice3: costPrice3,
            currency1: currency1,
            currency2: currency2,
            currency3: currency3,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemCode,
            required String itemName,
            required String groupCode,
            required String currencyCode,
            required String defaultUnit,
            required bool isActive,
            required String tabName,
            required int columnIndex,
            required int rowIndex,
            required String unit1,
            required String barcode1,
            required double shopPrice1,
            required double consumerPrice1,
            required String unit2,
            required String barcode2,
            required double shopPrice2,
            required double consumerPrice2,
            required String unit3,
            required String barcode3,
            required double shopPrice3,
            required double consumerPrice3,
            Value<double> minPrice1 = const Value.absent(),
            Value<double> minPrice2 = const Value.absent(),
            Value<double> minPrice3 = const Value.absent(),
            Value<double> costPrice1 = const Value.absent(),
            Value<double> costPrice2 = const Value.absent(),
            Value<double> costPrice3 = const Value.absent(),
            Value<String> currency1 = const Value.absent(),
            Value<String> currency2 = const Value.absent(),
            Value<String> currency3 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsTableCompanion.insert(
            id: id,
            itemCode: itemCode,
            itemName: itemName,
            groupCode: groupCode,
            currencyCode: currencyCode,
            defaultUnit: defaultUnit,
            isActive: isActive,
            tabName: tabName,
            columnIndex: columnIndex,
            rowIndex: rowIndex,
            unit1: unit1,
            barcode1: barcode1,
            shopPrice1: shopPrice1,
            consumerPrice1: consumerPrice1,
            unit2: unit2,
            barcode2: barcode2,
            shopPrice2: shopPrice2,
            consumerPrice2: consumerPrice2,
            unit3: unit3,
            barcode3: barcode3,
            shopPrice3: shopPrice3,
            consumerPrice3: consumerPrice3,
            minPrice1: minPrice1,
            minPrice2: minPrice2,
            minPrice3: minPrice3,
            costPrice1: costPrice1,
            costPrice2: costPrice2,
            costPrice3: costPrice3,
            currency1: currency1,
            currency2: currency2,
            currency3: currency3,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductsTableData,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (
      ProductsTableData,
      BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData>
    ),
    ProductsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
}
