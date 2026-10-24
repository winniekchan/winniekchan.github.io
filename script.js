// Mobile menu toggle
const toggle = document.querySelector(".nav-toggle");
const links = document.getElementById("nav-links");

toggle.addEventListener("click", () => {
  const open = toggle.getAttribute("aria-expanded") === "true";
  toggle.setAttribute("aria-expanded", String(!open));
  links.classList.toggle("open", !open);
});

// Close the menu after choosing a section
links.addEventListener("click", (e) => {
  if (e.target.closest("a")) {
    toggle.setAttribute("aria-expanded", "false");
    links.classList.remove("open");
  }
});

// Let sticky elements (the Kepler heading) sit just below the sticky header
const header = document.querySelector(".site-header");
const setHeaderHeight = () =>
  document.documentElement.style.setProperty("--header-h", header.offsetHeight + "px");
setHeaderHeight();
new ResizeObserver(setHeaderHeight).observe(header);

// Keep the footer year current
document.getElementById("year").textContent = new Date().getFullYear();
