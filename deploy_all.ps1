# 1️⃣ Delete old build folders if they exist
if (Test-Path build/web_surau) { Remove-Item -Recurse -Force build/web_surau }
if (Test-Path build/web_paid) { Remove-Item -Recurse -Force build/web_paid }

# 2️⃣ Build Admin Surau
flutter build web --target lib/main_surau.dart
Move-Item -Path build/web -Destination build/web_surau

# 3️⃣ Build Admin Paid
flutter build web --target lib/main_paid.dart
Move-Item -Path build/web -Destination build/web_paid

# 4️⃣ Apply Firebase hosting targets (if not applied yet)
firebase target:apply hosting surau nursurau2
firebase target:apply hosting paid nursurau2

# 5️⃣ Deploy
firebase deploy --only hosting:surau
firebase deploy --only hosting:paid
