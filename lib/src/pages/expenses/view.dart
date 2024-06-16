import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ExpensesView extends ResponsiveViewState {
  ExpensesView() : super(create: () => ExpensesController());
  @override
  Widget get desktopView => View();

  @override
  Widget get mobileView => View();

  @override
  Widget get tabletView => View();

  @override
  Widget get watchView => View();
}

class View extends StatefulWidget {
  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  late Future<ExpensesResponse?> _future;

  @override
  void initState() {
    super.initState();
    _future = ExpensesController().getExpenses();
  }

  String? selectedValue = "Food";

  bool isSaving = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ExpensesResponse?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          return Container(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    height: 32,
                    color: Colors.black87,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today",
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "+ ${snapshot.data!.saved}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "- ${snapshot.data!.spent}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: 54,
                    color:
                        isSaving ? Colors.green.shade900 : Colors.red.shade900,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        MaterialButton(
                          onPressed: () =>
                              {setState(() => isSaving = !isSaving)},
                          color: isSaving ? Colors.green : Colors.red,
                          minWidth: 8,
                          child: Icon(
                            isSaving ? Icons.add_rounded : Icons.remove,
                            color: Colors.white,
                          ),
                          elevation: 0.5,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]+.?[0-9]*'))
                            ],
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.0',
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              borderRadius: BorderRadius.circular(10),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              hint: Text(
                                "For what?",
                                textAlign: TextAlign.center,
                              ),
                              value: selectedValue,
                              isDense: true,
                              alignment: Alignment.center,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedValue = newValue;
                                });
                              },
                              items: ["Food", "Clothing", "Shelter"]
                                  .map((document) {
                                return DropdownMenuItem<String>(
                                  value: document,
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      document,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        MaterialButton(
                          onPressed: () => {},
                          color: Colors.black,
                          minWidth: 0,
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.orangeAccent,
                          ),
                          splashColor: Colors.transparent,
                          elevation: 0.5,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
