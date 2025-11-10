

function myFunction() {
  var x = document.getElementById("myLinks");
  if (x.style.display === "block") {
    x.style.display = "none";
  } else {
    x.style.display = "block";
  }
}


//Data: assume we have a list of top 5 movies
let Slideshow = 
[{ id: 0, title: "About", image_url: "images/about.jpg", image_link: "about.html" },
{ id: 1, title: "Recipes", image_url: "images/recipe.jpg", image_link: "recipes.html" },
{ id: 2, title: "Shopping Tips", image_url: "images/shopping_tips.jpg", image_link: "shopping_tips.html" },
{ id: 3, title: "Student-Friendly Eats", image_url: "images/restaurant.png", image_link: "student-friendly_eats.html" },
{ id: 4, title: "Sign Up", image_url: "images/sign_up.jpg", image_link: "sign_up.html" }
];
//Slideshow: Automatic
let autoSlideIndex = 0; //Initial slide = 0
function autoSlideShow() {
  //Change the slide_index
  if (autoSlideIndex < Slideshow.length - 1) {
    autoSlideIndex++;
  } else {
    autoSlideIndex = 0;
  }
  //Change the image source for the img
  document.getElementById("auto-slide-title").innerHTML = Slideshow[autoSlideIndex].title;
  document.getElementById("auto-slide-image").src = Slideshow[autoSlideIndex].image_url;
  document.getElementById("auto-slide-link").href = Slideshow[autoSlideIndex].image_link;
  //Wait 2 seconds
  setTimeout(autoSlideShow, 2000);//Auto change slide every 2 seconds
}
autoSlideShow() // Call to run auto slideshow





  const first = photos[0];
  const { width, height } = first.getBoundingClientRect();

  photos.forEach(img => {
    img.style.width = `${width}px`;
    img.style.height = `${height}px`;
    img.style.objectFit = 'cover';
  });

  document.getElementById('signupForm').addEventListener('submit', function(event) {

      event.preventDefault(); // stop page from reloading
 
      const name = document.getElementById('name').value.trim();

      const email = document.getElementById('email').value.trim();

      const mobile = document.getElementById('mobile').value.trim();

      const consent = document.getElementById('consent').checked;
 
      if (!name || !email || !mobile) {

        document.getElementById('message').textContent = 'Please fill out all required fields.';

        document.getElementById('message').style.color = 'red';

        return;

      }
 
      // Create a user object

      const user = { name, email, mobile, consent };
 
      // Retrieve existing users from localStorage

      let users = JSON.parse(localStorage.getItem('signupUsers')) || [];
 
      // Add new user

      users.push(user);
 
      // Save updated list

      localStorage.setItem('signupUsers', JSON.stringify(users));
 
      // Reset form

      document.getElementById('signupForm').reset();
 
      // Show confirmation message

      document.getElementById('message').textContent = 'Thanks for signing up!';

      document.getElementById('message').style.color = 'green';
 
      console.log('Current stored users:', users);

    });