// Register ScrollTrigger plugin
gsap.registerPlugin(ScrollTrigger);

document.addEventListener('DOMContentLoaded', () => {

// Get progress bar elements
const progressBar = document.querySelector('.progress-bar');
const progressFill = document.querySelector('.progress-fill');

// Activate progress bar
progressBar.classList.add('active');

// Create section markers
const sections = document.querySelectorAll('[data-section-name]');
const markers = [];

console.log('Found sections:', sections.length);

sections.forEach((section, index) => {
  const sectionName = section.getAttribute('data-section-name');
  console.log('Creating marker for:', sectionName);
  
  const marker = document.createElement('div');
  marker.className = 'progress-marker';
  marker.dataset.index = index;
  
  const label = document.createElement('div');
  label.className = 'progress-label';
  label.textContent = sectionName;
  
  progressBar.appendChild(marker);
  progressBar.appendChild(label);
  
  markers.push({ marker, label, section });
});

// Update progress bar on scroll
function updateProgressAndMarkers() {
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
  const scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
  const scrollProgress = (scrollTop / scrollHeight) * 100;
  
  progressFill.style.height = scrollProgress + '%';
  
  markers.forEach(({ marker, label, section }, index) => {
    const rect = section.getBoundingClientRect();
    const sectionTop = rect.top + scrollTop;
    const sectionPosition = (sectionTop / scrollHeight) * 100;
    
    marker.style.top = sectionPosition + '%';
    label.style.top = sectionPosition + '%';
    
    const viewportCenter = window.innerHeight / 2;
    const isActive = rect.top < viewportCenter && rect.bottom > viewportCenter;
    const isIntroduction = section.getAttribute('data-section-name') === 'Introduction';
    
    if (isIntroduction) {
      if (rect.bottom > 0 && rect.top < window.innerHeight) {
        marker.classList.add('active');
      } else {
        marker.classList.remove('active');
      }
    } else {
      if (isActive) {
        marker.classList.add('active');
      } else {
        marker.classList.remove('active');
      }
    }
  });
}

window.addEventListener('scroll', updateProgressAndMarkers);
updateProgressAndMarkers();

// Card animations
document.querySelectorAll(".js-scale").forEach((el) => {
  
  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: el,
      start: "center center",
      end: "+=3500", 
      scrub: 1.5, 
      pin: true,
      // markers: true,
    },
  });

  // Phase 1: Scale up
  tl.fromTo(
    el,
    { scale: 0.1, opacity: -1 },
    { 
      scale: 1.0,
      opacity: 1,
      ease: "power2.out",
      duration: 1
    }
  )
  
  // Phase 2: Scroll content
  .to(el, {
    scrollTop: el.scrollHeight - el.clientHeight,
    duration: 0.8,
    ease: "none",
  })
  
  // Phase 3: Fade out to the right
  .to(el, {
    x: "100vw", 
    scale: 0.8,
    opacity: -1,
    duration: 0.8,
    ease: "power2.in",
  });
});

// Hero animation (simple scale effect)
gsap.fromTo(
  "#hero",
  { 
    scale: 0.98,
    opacity: 0.95
  },
  {
    scale: 1.02,
    duration: 1.2,
    ease: "power2.out",
    
    scrollTrigger: {
      trigger: "#hero",
      start: "top center",
      end: "bottom center",
      scrub: 0.6,
    },
  }
);

}); // End DOMContentLoaded
