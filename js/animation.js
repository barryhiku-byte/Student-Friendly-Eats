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
  
  // Fixed position based on index
  const spacing = 100 / (sections.length - 1); // Spread evenly
  const position = index * spacing;
  label.style.top = position + '%';
  marker.style.top = position + '%';
  
  // Higher z-index for labels higher up (reverse index)
  label.style.zIndex = 100 + (sections.length - index);
  
  progressBar.appendChild(marker);
  progressBar.appendChild(label);
  
 
  label.addEventListener('click', () => {
    
    const sectionTop = section.getBoundingClientRect().top + window.pageYOffset;
    
    // Calculate where center would be (where animation starts)
    const viewportCenter = window.innerHeight / 1;
    const scrollToCenterPosition = sectionTop - viewportCenter;
    
    // Check if scrolling up or down
    const currentScroll = window.pageYOffset;
    const scrollingDown = scrollToCenterPosition > currentScroll;
    
    // Adjust offset based on direction
    const skipPhase1Offset = scrollingDown ? 1500 : 1;
    const finalPosition = scrollToCenterPosition + skipPhase1Offset;
    
    
    window.scrollTo({ 
      top: finalPosition,
      behavior: 'smooth' 
    });
  });
  
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
    
    const viewportCenter = window.innerHeight / 2;
    const isActive = rect.top < viewportCenter && rect.bottom > viewportCenter;
    const isIntroduction = section.getAttribute('data-section-name') === 'Introduction';
    
    // Only toggle active state - position is fixed
    if (isIntroduction) {
      if (rect.bottom > 0 && rect.top < window.innerHeight) {
        marker.classList.add('active');
        label.classList.add('active');
      } else {
        marker.classList.remove('active');
        label.classList.remove('active');
      }
    } else {
      if (isActive) {
        marker.classList.add('active');
        label.classList.add('active');
      } else {
        marker.classList.remove('active');
        label.classList.remove('active');
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
      end: "+=5000", 
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
      scale: 0.7,
      opacity: 1,
      ease: "power2.out",
      duration: 50,
    }
  )
  
  // Phase 2: Scroll content
  .to(el, {
    scrollTop: el.scrollHeight - el.clientHeight,
    duration: 50,
    ease: "none",
  })
  
  // Phase 3: Fade out (reverse of fade in)
  .to(el, {
    scale: 0.1,
    opacity: 0,
    duration: 50,
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
