import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/ui/app/forms/client_picker.dart';
import 'package:invoiceninja_flutter/ui/app/forms/custom_field.dart';
import 'package:invoiceninja_flutter/ui/app/forms/date_picker.dart';
import 'package:invoiceninja_flutter/ui/app/forms/decorated_form_field.dart';
import 'package:invoiceninja_flutter/ui/app/forms/discount_field.dart';
import 'package:invoiceninja_flutter/ui/app/forms/user_picker.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_details_vm.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_items_vm.dart';
import 'package:invoiceninja_flutter/ui/quote/edit/quote_edit_items_vm.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class InvoiceEditDesktop extends StatefulWidget {
  const InvoiceEditDesktop({
    Key key,
    @required this.viewModel,
    this.isQuote = false,
  }) : super(key: key);

  final EntityEditDetailsVM viewModel;
  final bool isQuote;

  @override
  InvoiceEditDesktopState createState() => InvoiceEditDesktopState();
}

class InvoiceEditDesktopState extends State<InvoiceEditDesktop>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  final _invoiceNumberController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _discountController = TextEditingController();
  final _partialController = TextEditingController();
  final _custom1Controller = TextEditingController();
  final _custom2Controller = TextEditingController();
  final _custom3Controller = TextEditingController();
  final _custom4Controller = TextEditingController();
  final _surcharge1Controller = TextEditingController();
  final _surcharge2Controller = TextEditingController();
  final _designController = TextEditingController();
  final _publicNotesController = TextEditingController();
  final _privateNotesController = TextEditingController();
  final _termsController = TextEditingController();
  final _footerController = TextEditingController();

  List<TextEditingController> _controllers = [];
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  void didChangeDependencies() {
    _controllers = [
      _invoiceNumberController,
      _poNumberController,
      _discountController,
      _partialController,
      _custom1Controller,
      _custom2Controller,
      _custom3Controller,
      _custom4Controller,
      _surcharge1Controller,
      _surcharge2Controller,
      _designController,
      _publicNotesController,
      _privateNotesController,
      _termsController,
      _footerController,
    ];

    _controllers
        .forEach((dynamic controller) => controller.removeListener(_onChanged));

    final invoice = widget.viewModel.invoice;
    _invoiceNumberController.text = invoice.number;
    _poNumberController.text = invoice.poNumber;
    _discountController.text = formatNumber(invoice.discount, context,
        formatNumberType: FormatNumberType.input);
    _partialController.text = formatNumber(invoice.partial, context,
        formatNumberType: FormatNumberType.input);
    _custom1Controller.text = invoice.customValue1;
    _custom2Controller.text = invoice.customValue2;
    _custom3Controller.text = invoice.customValue3;
    _custom4Controller.text = invoice.customValue4;
    _surcharge1Controller.text = formatNumber(invoice.customSurcharge1, context,
        formatNumberType: FormatNumberType.input);
    _surcharge2Controller.text = formatNumber(invoice.customSurcharge2, context,
        formatNumberType: FormatNumberType.input);
    _designController.text =
        invoice.designId != null ? kInvoiceDesigns[invoice.designId] : '';
    _publicNotesController.text = invoice.publicNotes;
    _privateNotesController.text = invoice.privateNotes;
    _termsController.text = invoice.terms;
    _footerController.text = invoice.footer;

    _controllers
        .forEach((dynamic controller) => controller.addListener(_onChanged));

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.forEach((controller) {
      controller.removeListener(_onChanged);
      controller.dispose();
    });

    super.dispose();
  }

  void _onChanged() {
    _debouncer.run(() {
      final invoice = widget.viewModel.invoice.rebuild((b) => b
        ..number = widget.viewModel.invoice.isNew
            ? ''
            : _invoiceNumberController.text.trim()
        ..poNumber = _poNumberController.text.trim()
        ..discount = parseDouble(_discountController.text)
        ..partial = parseDouble(_partialController.text)
        ..customValue1 = _custom1Controller.text.trim()
        ..customValue2 = _custom2Controller.text.trim()
        ..customValue3 = _custom3Controller.text.trim()
        ..customValue4 = _custom4Controller.text.trim()
        ..customSurcharge1 = parseDouble(_surcharge1Controller.text)
        ..customSurcharge2 = parseDouble(_surcharge2Controller.text)
        ..publicNotes = _publicNotesController.text.trim()
        ..privateNotes = _privateNotesController.text.trim()
        ..terms = _termsController.text.trim()
        ..footer = _footerController.text.trim());
      if (invoice != widget.viewModel.invoice) {
        widget.viewModel.onChanged(invoice);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;
    final invoice = viewModel.invoice;

    return ListView(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: FormCard(
                padding: const EdgeInsets.only(
                    top: kMobileDialogPadding,
                    right: kMobileDialogPadding / 2,
                    bottom: kMobileDialogPadding,
                    left: kMobileDialogPadding),
                children: <Widget>[
                  if (invoice.isNew)
                    ClientPicker(
                      clientId: invoice.clientId,
                      clientState: viewModel.state.clientState,
                      onSelected: (client) =>
                          viewModel.onClientChanged(invoice, client),
                      onAddPressed: (completer) =>
                          viewModel.onAddClientPressed(context, completer),
                    ),
                  UserPicker(
                    userId: invoice.assignedUserId,
                    onChanged: (userId) => viewModel.onChanged(
                        invoice.rebuild((b) => b..assignedUserId = userId)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FormCard(
                padding: const EdgeInsets.only(
                    top: kMobileDialogPadding,
                    right: kMobileDialogPadding / 2,
                    bottom: kMobileDialogPadding,
                    left: kMobileDialogPadding / 2),
                children: <Widget>[
                  DatePicker(
                    validator: (String val) => val.trim().isEmpty
                        ? AppLocalization.of(context).pleaseSelectADate
                        : null,
                    labelText: widget.isQuote
                        ? localization.quoteDate
                        : localization.invoiceDate,
                    selectedDate: invoice.date,
                    onSelected: (date) {
                      viewModel
                          .onChanged(invoice.rebuild((b) => b..date = date));
                    },
                  ),
                  DatePicker(
                    labelText: widget.isQuote
                        ? localization.validUntil
                        : localization.dueDate,
                    selectedDate: invoice.dueDate,
                    onSelected: (date) {
                      viewModel
                          .onChanged(invoice.rebuild((b) => b..dueDate = date));
                    },
                  ),
                  DecoratedFormField(
                    label: localization.partialDeposit,
                    controller: _partialController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (invoice.partial != null && invoice.partial > 0)
                    DatePicker(
                      labelText: localization.partialDueDate,
                      selectedDate: invoice.partialDueDate,
                      onSelected: (date) {
                        viewModel.onChanged(
                            invoice.rebuild((b) => b..partialDueDate = date));
                      },
                    ),
                  CustomField(
                    controller: _custom1Controller,
                    field: CustomFieldType.invoice1,
                    value: invoice.customValue1,
                  ),
                  CustomField(
                    controller: _custom2Controller,
                    field: CustomFieldType.invoice2,
                    value: invoice.customValue2,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FormCard(
                padding: const EdgeInsets.only(
                    top: kMobileDialogPadding,
                    right: kMobileDialogPadding,
                    bottom: kMobileDialogPadding,
                    left: kMobileDialogPadding / 2),
                children: <Widget>[
                  DecoratedFormField(
                    controller: _invoiceNumberController,
                    label: widget.isQuote
                        ? localization.quoteNumber
                        : localization.invoiceNumber,
                    validator: (String val) => val.trim().isEmpty &&
                            invoice.isOld
                        ? AppLocalization.of(context).pleaseEnterAnInvoiceNumber
                        : null,
                  ),
                  DecoratedFormField(
                    label: localization.poNumber,
                    controller: _poNumberController,
                  ),
                  DiscountField(
                    controller: _discountController,
                    value: invoice.discount,
                    isAmountDiscount: invoice.isAmountDiscount,
                    onTypeChanged: (value) => viewModel.onChanged(
                        invoice.rebuild((b) => b..isAmountDiscount = value)),
                  ),
                  CustomField(
                    controller: _custom2Controller,
                    field: CustomFieldType.invoice2,
                    value: invoice.customValue2,
                  ),
                  CustomField(
                    controller: _custom4Controller,
                    field: CustomFieldType.invoice4,
                    value: invoice.customValue4,
                  ),
                ],
              ),
            ),
          ],
        ),
        widget.isQuote ? QuoteEditItemsScreen() : InvoiceEditItemsScreen(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: FormCard(
                children: <Widget>[
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: localization.publicNotes),
                      Tab(text: localization.privateNotes),
                      Tab(text: localization.terms),
                      Tab(text: localization.footer),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        DecoratedFormField(
                          maxLines: 6,
                          controller: _publicNotesController,
                          keyboardType: TextInputType.multiline,
                          label: '',
                        ),
                        DecoratedFormField(
                          maxLines: 6,
                          controller: _privateNotesController,
                          keyboardType: TextInputType.multiline,
                          label: '',
                        ),
                        DecoratedFormField(
                          maxLines: 6,
                          controller: _termsController,
                          keyboardType: TextInputType.multiline,
                          label: '',
                        ),
                        DecoratedFormField(
                          maxLines: 6,
                          controller: _footerController,
                          keyboardType: TextInputType.multiline,
                          label: '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: FormCard(
                children: <Widget>[
                  DecoratedFormField(
                    enabled: false,
                    initialValue: '10',
                    label: localization.subtotal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}