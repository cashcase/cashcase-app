import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:action_slider/action_slider.dart';

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

  bool restoringKey = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !confirmed,
      ),
      body: Container(
        padding: EdgeInsets.all(16).copyWith(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Set Your Encryption Key".replaceAll(" ", "\n"),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(height: 24),
                Text(
                    "Please copy and securely store your key. This key can only be generated once per account and cannot be recovered if lost.",
                    style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 8),
                Theme(
                  data: ThemeData(splashFactory: NoSplash.splashFactory),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () =>
                        setState(() => restoringKey = !restoringKey),
                    color: Colors.transparent,
                    child: Text(
                      "Click here if ${restoringKey ? "you already need to generate a new key." : "you already have a key."}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                if (!restoringKey)
                  Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "${newKeyController.text}\n",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              newKeyController.text =
                                  Encrypter.generateRandomKey();
                              keyCopied = null;
                            }),
                            child: Icon(
                              Icons.refresh_rounded,
                              color: Colors.black54,
                              size: 28,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: newKeyController.text.isEmpty
                                ? null
                                : () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                          text: newKeyController.text),
                                    );
                                    setState(() =>
                                        keyCopied = newKeyController.text);
                                  },
                            child: Icon(
                              newKeyController.text == keyCopied
                                  ? Icons.check_circle_rounded
                                  : Icons.copy_rounded,
                              color: Colors.black54,
                              size: 28,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                if (restoringKey)
                  TextField(
                    controller: oldKeyController,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Restore Encrpytion Key',
                      hintStyle: TextStyle(color: Colors.grey),
                      errorMaxLines: 2,
                      errorStyle: TextStyle(color: Colors.red),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade800, width: 1.0),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24),
            if (!restoringKey && newKeyController.text == keyCopied)
              showNewKeySlider(),
            if (restoringKey) showRestoreKeySlider()
          ],
        ),
      ),
    );
  }

  showRestoreKeySlider() {
    return ActionSlider.standard(
      controller: sliderController,
      sliderBehavior: SliderBehavior.move,
      child: Text(
        "Enter key and slide to confirm",
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
        if (oldKeyController.text.isEmpty) return;
        setState(() => confirmed = true);
        controller.loading();
        await Future.delayed(Duration(milliseconds: 500));
        await AppDb.setEncryptionKey(oldKeyController.text);
        controller.success();
        context.once<AppController>().loader.show();
        context.clearAndReplace("/");
      },
    );
  }

  showNewKeySlider() {
    return ActionSlider.standard(
      controller: sliderController,
      sliderBehavior: SliderBehavior.move,
      child: Text(
        newKeyController.text != keyCopied
            ? "Copy your key"
            : "Slide to Confirm",
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
        context.once<AppController>().loader.show();
        context.clearAndReplace("/");
      },
    );
  }
}
