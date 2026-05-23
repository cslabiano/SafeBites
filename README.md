<h1>SafeBites</h1>

SafeBite is an Android mobile application that helps users identify Filipino food items and check for potential allergens. The app uses image recognition to detect food from captured or uploaded images, then cross-references the detected food with a locally stored database to display ingredients and allergen information.

<h2>Features</h2>
<ul>
  <li>Capture food images using the camera
  <li>Upload food images from gallery
  <li>Filipino food recognition using YOLOv11s
  <li>Allergen detection based on ingredients
  <li>Search food items manually
  <li>Offline image recognition and database access
  <li>Featured foods section
  <li>Custom avoided allergens filter
</ul>

<h2>Screenshots</h2>
<h3>Splash Screen and Dashboard</h3>
<p align="left"> <img src="screenshots/splashscreen.jpg" width="250"/>
<img src="screenshots/dashboard.jpg" width="250"/> </p>
<h3>Search and Food Info</h3>
<p align="left"> s<img src="screenshots/search.jpg" width="250"/>
<img src="screenshots/food-info.jpg" width="250"/>
<img src="screenshots/food-info-2.jpg" width="250"/> </p>
<h3>Camera and Results Screens</h3>
<p align="left"> <img src="screenshots/camera.jpg" width="250"/>
<img src="screenshots/good-alert.jpg" width="250"/>
<img src="screenshots/bad-alert.jpg" width="250"/> </p>
<h3>Allergens and Allergen Info</h3>
<p align="left"> <img src="screenshots/allergens.jpg" width="250"/>
<img src="screenshots/allergen-info.jpg" width="250"/>
<img src="screenshots/allergen-info-2.jpg" width="250"/> </p>

<h2>Tech Stack</h2>
<ul>
  <li>Flutter
  <li>Dart
  <li>SQLite
  <li>TensorFlow Lite (TFLite)
  <li>YOLOv11s
</ul>

<h2>How It Works</h2>
<ol>
  <li>The user captures or uploads an image.
  <li>The YOLOv11s model detects Filipino food items in the image.
  <li>The app retrieves ingredient and allergen data from a local SQLite database.
  <li>The app warns users if detected foods contain avoided allergens.
</ol>


