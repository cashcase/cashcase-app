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
  TextEditingController keyController =
      TextEditingController(text: AppDb.getRandomKey());
  ActionSliderController sliderController = ActionSliderController();

  String? keyCopied = null;
  bool confirmed = false;

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
                Text("Set Your Encryption Key".replaceAll(" ", "\n"),
                    style: Theme.of(context).textTheme.displayLarge),
                SizedBox(
                  height: 24,
                ),
                Text(
                    "Please copy and securely store your key. This key can only be generated once per account and cannot be recovered if lost.",
                    style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(
                  height: 24,
                ),
                Container(
                  height: 200,
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
                            "${keyController.text}\n",
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
                            keyController.text = AppDb.getRandomKey();
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
                          onTap: keyController.text.isEmpty
                              ? null
                              : () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: keyController.text),
                                  );
                                  setState(
                                      () => keyCopied = keyController.text);
                                },
                          child: Icon(
                            keyController.text == keyCopied
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
              ],
            ),
            if (keyController.text == keyCopied)
              ActionSlider.standard(
                controller: sliderController,
                sliderBehavior: SliderBehavior.move,
                child: Text(
                  keyController.text != keyCopied
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
                  await Future.delayed(const Duration(seconds: 1));
                  await AppDb.setEncryptionKey(keyController.text);
                  controller.success();
                  context.once<AppController>().loader.show();
                  context.clearAndReplace("/");
                },
              )
          ],
        ),
      ),
    );
  }
}
