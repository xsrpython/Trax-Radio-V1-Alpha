@echo off
cd trax_radio
echo Upgrading dependencies...
flutter pub upgrade
echo Getting dependencies...
flutter pub get
echo Cleaning project...
flutter clean
echo All done! You can now open Android Studio and run your app.
pause 