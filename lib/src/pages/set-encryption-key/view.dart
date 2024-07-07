import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/components/button.dart';
import 'package:cashcase/src/components/text-field.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:action_slider/action_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class SetKeyView extends StatefulWidget {
  @override
  State<SetKeyView> createState() => _SetKeyViewState();
}

class _SetKeyViewState extends State<SetKeyView> {
  TextEditingController newKeyController =
      TextEditingController(text: Encrypter.generateRandomKey());
  TextEditingController oldKeyController = TextEditingController();
  ActionSliderController sliderController = ActionSliderController();

  String? keyCopied = null;
  bool confirmed = false;

  String? oldKeyError = null;

  bool restoringKey = false;

  void handleClick(String value) {
    keyCopied = null;
    restoringKey = !restoringKey;
    oldKeyError = null;
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: !confirmed, actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: handleClick,
          color: Colors.black,
          popUpAnimationStyle: AnimationStyle.noAnimation,
          padding: EdgeInsets.all(0),
          // constraints: BoxConstraints.tightFor(width: 100),
          itemBuilder: (BuildContext context) {
            return (restoringKey ? {'Restore Key'} : {'Generate a New Key'})
                .map((String choice) {
              return PopupMenuItem<String>(
                padding: EdgeInsets.all(8),
                value: choice,
                child: Center(
                  child: Text(
                    choice,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList();
          },
        ),
      ]),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16).copyWith(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(Icons.lock_rounded,
                              size: 48, color: Colors.orangeAccent),
                        ),
                        SizedBox(height: 24),
                        Text(
                          "Set Your\n Encryption Key",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    if (!restoringKey)
                      Text(
                        "Please copy and securely store your key. This key can only be generated once per account and cannot be recovered if lost.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.white),
                      ),
                    if (!restoringKey) SizedBox(height: 16),
                    if (!restoringKey)
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "${newKeyController.text}",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: GoogleFonts.poppinsTextTheme()
                                      .displayLarge!
                                      .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!restoringKey) SizedBox(height: 8),
                    if (!restoringKey)
                      Row(
                        children: [
                          Expanded(
                            child: Button(
                              label: newKeyController.text == keyCopied
                                  ? "Copied!"
                                  : "Copy Key",
                              color: newKeyController.text == keyCopied
                                  ? Colors.green.shade600
                                  : null,
                              type: ButtonType.secondary,
                              onPressed: newKeyController.text.isEmpty
                                  ? null
                                  : () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                            text: newKeyController.text),
                                      );
                                      setState(() =>
                                          keyCopied = newKeyController.text);
                                    },
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Button(
                              label: "Generate New Key",
                              onPressed: () => setState(() {
                                newKeyController.text =
                                    Encrypter.generateRandomKey();
                                keyCopied = null;
                              }),
                              type: ButtonType.secondary,
                            ),
                          )
                        ],
                      ),
                    if (restoringKey)
                      CustomTextField(
                        label: "Enter Encryption Key",
                        controller: oldKeyController,
                        error: oldKeyError,
                      ),
                  ],
                ),
                SizedBox(height: 16),
                if (!restoringKey && newKeyController.text == keyCopied)
                  showNewKeySlider(),
                if (restoringKey) showRestoreKeySlider()
              ],
            ),
          ),
        ),
      ),
    );
  }

  showRestoreKeySlider() {
    return ActionSlider.standard(
      controller: sliderController,
      sliderBehavior: SliderBehavior.move,
      child: Text(
        "Slide to confirm",
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white30,
            ),
      ),
      backgroundBorderRadius: BorderRadius.all(Radius.circular(8)),
      foregroundBorderRadius: BorderRadius.all(Radius.circular(8)),
      toggleColor: Colors.orangeAccent,
      backgroundColor: Colors.white10,
      icon: Icon(
        Icons.keyboard_arrow_right_rounded,
        color: Colors.black,
      ),
      loadingIcon: CircularProgressIndicator(
        color: Colors.black,
      ),
      successIcon: Icon(
        Icons.check_rounded,
        color: Colors.black,
      ),
      failureIcon: Icon(
        Icons.close_rounded,
        color: Colors.black,
      ),
      action: (controller) async {
        oldKeyError = isValidKey(oldKeyController.value.text);
        if (oldKeyError != null) return setState(() => {});
        setState(() => confirmed = true);
        controller.loading();
        await Future.delayed(Duration(milliseconds: 500));
        await AppDb.setEncryptionKey(oldKeyController.text);
        controller.success();
        context.clearAndReplace("/");
      },
    );
  }

  showNewKeySlider() {
    return ActionSlider.standard(
      controller: sliderController,
      backgroundBorderRadius: BorderRadius.all(Radius.circular(8)),
      foregroundBorderRadius: BorderRadius.all(Radius.circular(8)),
      sliderBehavior: SliderBehavior.move,
      child: Text(
        "Slide to confirm",
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.white),
      ),
      toggleColor: Colors.orangeAccent,
      backgroundColor: Colors.white10,
      icon: Icon(
        Icons.keyboard_arrow_right_rounded,
        color: Colors.black,
      ),
      loadingIcon: CircularProgressIndicator(
        color: Colors.black,
      ),
      successIcon: Icon(
        Icons.check_rounded,
        color: Colors.black,
      ),
      failureIcon: Icon(
        Icons.close_rounded,
        color: Colors.black,
      ),
      action: (controller) async {
        setState(() => confirmed = true);
        controller.loading();
        await Future.delayed(Duration(milliseconds: 500));
        await AppDb.setEncryptionKey(newKeyController.text);
        controller.success();
        context.clearAndReplace("/");
      },
    );
  }
}
