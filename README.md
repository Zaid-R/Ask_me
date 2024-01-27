
# Ask Me

This app is made to answer your questions, but not by any one, only by experts.


<p align="center">
<img src="https://lh3.googleusercontent.com/u/0/drive-viewer/AEYmBYRrgrSuiU8ExhPwrRrSlN-5kThE_oYCPKoeTEVGHcdmfX10P97pSSeoj-_YHvcnAmM6RQ89_1tStgKJQmQlxMpzg-ui=w1920-h941">
</p>

## How it works ?

This app is divided into three sections:
1. User
     <br>user is able to:
     1. Ask questions, he can add photo or video in the question, but that's in some categories where user may need to do so
     2. See all of his questions, red color means his question is reported by an expert, green color means his question has been answered, and blue color means his question not answered yet
  
2. Expert<br>
   expert is able to:
   1. Answer questions
   2. Report questions
   3. See his answers and reports
      
3. Admin<br>
   admin is able to:
   1. See all questions
   2. Hide questions, so it will not appear to user
   3. Accept the request of new expert to join the app or reject it
   4. Suspend or activate any account (expert's account or user's account), so if the account get suspended by the admin it will not be able to enter the app till the admin activate/unsuspend it
   5. See the info of any account

## Let's take a look
![](https://github.com/Zaid-R/Ask_me/blob/main/assets/registration%20pages.gif)

- Validation applied
- In expert sign up, he has to upload his degree as pdf file, if the file is not pdf then a dialog will appear to alert him
- In user sign up, user should be at least 16 years old, otherwise a dialog will appear to alert him
- If you forgot password, the app will send verification code to your email which you have to write it in the text field inside the app, then you can change your password
- You'll be loged in till you log out from the app by yourself
  ##
  <h3>User section</h3><br>
![](https://github.com/Zaid-R/Ask_me/blob/main/assets/user%20section.gif)

- Answered questions only will appear to user in each category
  <br/><br/><br/>
![](https://github.com/Zaid-R/Ask_me/blob/main/assets/questioning.gif)

- On the left, user can see question even if he isn't loged in, but if he tried to ask a question then a snackbar will appear then after 2 seconds he will be directed to log in page
- On the right, user can ask question after log in, and he can hide his name, so his name will not appear on the question title
- The user can ask 3 questions a day, if he tried to ask more then dialog will appear to alert him
##
<h3>Expert section</h3><br>

![](https://github.com/Zaid-R/Ask_me/blob/main/assets/expert%20pages.gif)

##
<h3>Admin section</h3><br>

![](https://github.com/Zaid-R/Ask_me/blob/main/assets/admin%20pages.gif)

- When the admin accepts an expert, app will send email to this expert to give him the ID that he will use it to enter the app
- Admin can search for an expert by his ID
##
<h3>No internet connection</h3><br>

![](https://github.com/Zaid-R/Ask_me/blob/main/assets/internet%20is%20off.jpg)

- This image will be displayed when user has no access to the internet
## Packages
- cached_network_image
- cloud_firestore 
- firebase_auth
- firebase_core
- firebase_storage
- cloud_functions
- file_picker
- video_player
- rxdart
- get_storage
- google_fonts
- image_picker
- advance_pdf_viewer2
- intl
- provider
- http:
- flutter_offline
- mailer: ^6.0.1
- random_string: ^2.3.1
- animated_text_kit: ^4.2.2
##
Let me know if you have any questions, and feel free to contribute.<br/>
If you liked my work, don’t forget to ⭐ star the repository to show your support.
  
