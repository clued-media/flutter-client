import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/product/product_selectors.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class ViewProductList extends AbstractNavigatorAction implements PersistUI {
  ViewProductList({@required NavigatorState navigator, this.force = false})
      : super(navigator: navigator);

  final bool force;
}

class ViewProduct extends AbstractNavigatorAction
    implements PersistUI, PersistPrefs {
  ViewProduct(
      {@required this.productId,
      @required NavigatorState navigator,
      this.force = false})
      : super(navigator: navigator);

  final String productId;
  final bool force;
}

class EditProduct extends AbstractNavigatorAction
    implements PersistUI, PersistPrefs {
  EditProduct(
      {@required this.product,
      @required NavigatorState navigator,
      this.completer,
      this.force = false})
      : super(navigator: navigator);

  final ProductEntity product;
  final Completer completer;
  final bool force;
}

class UpdateProduct implements PersistUI {
  UpdateProduct(this.product);

  final ProductEntity product;
}

class LoadProducts {
  LoadProducts({this.completer, this.force = false});

  final Completer completer;
  final bool force;
}

class LoadProductsRequest implements StartLoading {}

class LoadProductsFailure implements StopLoading {
  LoadProductsFailure(this.error);

  final dynamic error;

  @override
  String toString() {
    return 'LoadProductsFailure{error: $error}';
  }
}

class LoadProductsSuccess implements PersistData, StopLoading {
  LoadProductsSuccess(this.products);

  final BuiltList<ProductEntity> products;

  @override
  String toString() {
    return 'LoadProductsSuccess{products: $products}';
  }
}

class SaveProductRequest implements StartSaving {
  SaveProductRequest({this.product, this.completer});

  final Completer completer;
  final ProductEntity product;
}

class SaveProductSuccess implements StopSaving, PersistData, PersistUI {
  SaveProductSuccess(this.product);

  final ProductEntity product;
}

class AddProductSuccess implements StopSaving, PersistData, PersistUI {
  AddProductSuccess(this.product);

  final ProductEntity product;
}

class SaveProductFailure implements StopSaving {
  SaveProductFailure(this.error);

  final Object error;
}

class ArchiveProductRequest implements StartSaving {
  ArchiveProductRequest(this.completer, this.productIds);

  final Completer completer;
  final List<String> productIds;
}

class ArchiveProductSuccess implements StopSaving, PersistData {
  ArchiveProductSuccess(this.products);

  final List<ProductEntity> products;
}

class ArchiveProductFailure implements StopSaving {
  ArchiveProductFailure(this.products);

  final List<ProductEntity> products;
}

class DeleteProductRequest implements StartSaving {
  DeleteProductRequest(this.completer, this.productIds);

  final Completer completer;
  final List<String> productIds;
}

class DeleteProductSuccess implements StopSaving, PersistData {
  DeleteProductSuccess(this.products);

  final List<ProductEntity> products;
}

class DeleteProductFailure implements StopSaving {
  DeleteProductFailure(this.products);

  final List<ProductEntity> products;
}

class RestoreProductRequest implements StartSaving {
  RestoreProductRequest(this.completer, this.productIds);

  final Completer completer;
  final List<String> productIds;
}

class RestoreProductSuccess implements StopSaving, PersistData {
  RestoreProductSuccess(this.products);

  final List<ProductEntity> products;
}

class RestoreProductFailure implements StopSaving {
  RestoreProductFailure(this.products);

  final List<ProductEntity> products;
}

class FilterProducts implements PersistUI {
  FilterProducts(this.filter);

  final String filter;
}

class SortProducts implements PersistUI {
  SortProducts(this.field);

  final String field;
}

class FilterProductsByState implements PersistUI {
  FilterProductsByState(this.state);

  final EntityState state;
}

class FilterProductsByCustom1 implements PersistUI {
  FilterProductsByCustom1(this.value);

  final String value;
}

class FilterProductsByCustom2 implements PersistUI {
  FilterProductsByCustom2(this.value);

  final String value;
}

class FilterProductDropdown {
  FilterProductDropdown(this.filter);

  final String filter;
}

void handleProductAction(
    BuildContext context, List<BaseEntity> products, EntityAction action) {
  assert(
      [
            EntityAction.restore,
            EntityAction.archive,
            EntityAction.delete,
            EntityAction.toggleMultiselect
          ].contains(action) ||
          products.length == 1,
      'Cannot perform this action on more than one product');

  if (products.isEmpty) {
    return;
  }

  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final localization = AppLocalization.of(context);
  final productIds = products.map((product) => product.id).toList();
  final product = products.first;

  switch (action) {
    case EntityAction.newInvoice:
      final item =
          convertProductToInvoiceItem(company: state.company, product: product);
      createEntity(
          context: context,
          entity: InvoiceEntity(state: state)
              .rebuild((b) => b..lineItems.add(item)));
      break;
    case EntityAction.edit:
      editEntity(context: context, entity: product);
      break;
    case EntityAction.clone:
      createEntity(context: context, entity: (product as ProductEntity).clone);
      break;
    case EntityAction.restore:
      store.dispatch(RestoreProductRequest(
          snackBarCompleter<Null>(context, localization.restoredProduct),
          productIds));
      break;
    case EntityAction.archive:
      store.dispatch(ArchiveProductRequest(
          snackBarCompleter<Null>(context, localization.archivedProduct),
          productIds));
      break;
    case EntityAction.delete:
      store.dispatch(DeleteProductRequest(
          snackBarCompleter<Null>(context, localization.deletedProduct),
          productIds));
      break;
    case EntityAction.toggleMultiselect:
      if (!store.state.productListState.isInMultiselect()) {
        store.dispatch(StartProductMultiselect());
      }

      if (products.isEmpty) {
        break;
      }

      for (final product in products) {
        if (!store.state.productListState.isSelected(product.id)) {
          store.dispatch(AddToProductMultiselect(entity: product));
        } else {
          store.dispatch(RemoveFromProductMultiselect(entity: product));
        }
      }
      break;
  }
}

class StartProductMultiselect {}

class AddToProductMultiselect {
  AddToProductMultiselect({@required this.entity});

  final BaseEntity entity;
}

class RemoveFromProductMultiselect {
  RemoveFromProductMultiselect({@required this.entity});

  final BaseEntity entity;
}

class ClearProductMultiselect {}
