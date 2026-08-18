// Theme toggle (persists via localStorage)
(function () {
  const root = document.documentElement;
  const saved = localStorage.getItem("theme");
  if (saved === "dark") root.classList.add("dark");

  document.addEventListener("DOMContentLoaded", () => {
    // --- Theme toggle ---
    const btn = document.querySelector(".theme-toggle");
    if (btn) {
      btn.addEventListener("click", () => {
        root.classList.toggle("dark");
        localStorage.setItem("theme", root.classList.contains("dark") ? "dark" : "light");
      });
    }

    // --- Mobile nav ---
    const navToggle = document.querySelector(".nav-toggle");
    const navRow = document.querySelector(".nav-row");
    if (navToggle && navRow) {
      navToggle.addEventListener("click", () => navRow.classList.toggle("open"));
    }

    // --- Cursor-reactive hero glow (desktop only, respects reduced motion) ---
    const glow = document.querySelector(".hero-glow");
    const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (glow && !prefersReduced && window.matchMedia("(min-width: 700px)").matches) {
      let raf = null;
      window.addEventListener("mousemove", (e) => {
        if (raf) return;
        raf = requestAnimationFrame(() => {
          const xPct = (e.clientX / window.innerWidth - 0.5) * 60;
          const yPct = (e.clientY / window.innerHeight - 0.5) * 40;
          glow.style.transform = `translate(calc(-50% + ${xPct}px), ${yPct}px)`;
          raf = null;
        });
      });
    }

    // --- Ambient moving-green background (soft drifting blobs, every page) ---
    (function () {
      const field = document.createElement("div");
      field.className = "bg-field";
      field.innerHTML =
        '<div class="bg-parallax" data-depth="18"><div class="bg-blob b1"></div></div>' +
        '<div class="bg-parallax" data-depth="12"><div class="bg-blob b2"></div></div>' +
        '<div class="bg-parallax" data-depth="24"><div class="bg-blob b3"></div></div>';
      document.body.insertBefore(field, document.body.firstChild);

      const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
      const isFinePointer = window.matchMedia("(pointer: fine)").matches;
      if (prefersReducedMotion || !isFinePointer) return;

      const layers = Array.from(field.querySelectorAll(".bg-parallax"));
      let raf = null;
      window.addEventListener("mousemove", (e) => {
        if (raf) return;
        raf = requestAnimationFrame(() => {
          const xPct = e.clientX / window.innerWidth - 0.5;
          const yPct = e.clientY / window.innerHeight - 0.5;
          layers.forEach((layer) => {
            const depth = parseFloat(layer.getAttribute("data-depth")) || 15;
            layer.style.transform = `translate(${xPct * depth}px, ${yPct * depth}px)`;
          });
          raf = null;
        });
      });
    })();

    // --- Sticky table of contents (project case-study pages) ---
    (function () {
      const aside = document.getElementById("toc");
      const body = document.querySelector(".case-body");
      if (!aside || !body) return;

      const blocks = Array.from(body.querySelectorAll(":scope > .block"));
      if (!blocks.length) return;

      const label = document.createElement("div");
      label.className = "toc-label";
      label.textContent = "Contents";
      const list = document.createElement("ul");

      const usedIds = new Set();
      const entries = [];

      blocks.forEach((block, i) => {
        const heading = block.querySelector("h2");
        if (!heading) return;
        let slug = heading.textContent
          .trim()
          .toLowerCase()
          .replace(/[^\w\s-]/g, "")
          .replace(/\s+/g, "-")
          .slice(0, 40) || ("section-" + i);
        let unique = slug;
        let n = 1;
        while (usedIds.has(unique) || document.getElementById(unique)) {
          unique = slug + "-" + n++;
        }
        usedIds.add(unique);
        block.id = unique;

        const li = document.createElement("li");
        const a = document.createElement("a");
        a.href = "#" + unique;
        a.textContent = heading.textContent.trim();
        li.appendChild(a);
        list.appendChild(li);
        entries.push({ id: unique, li: li });
      });

      if (!entries.length) return;
      aside.appendChild(label);
      aside.appendChild(list);

      if ("IntersectionObserver" in window) {
        const io = new IntersectionObserver(
          (observedEntries) => {
            observedEntries.forEach((observed) => {
              if (!observed.isIntersecting) return;
              const match = entries.find((e) => e.id === observed.target.id);
              if (!match) return;
              entries.forEach((e) => e.li.classList.remove("active"));
              match.li.classList.add("active");
            });
          },
          { rootMargin: "-15% 0px -70% 0px", threshold: 0 }
        );
        blocks.forEach((b) => io.observe(b));
      }
    })();

    // --- Scroll reveal ---
    const revealEls = document.querySelectorAll(".reveal");
    if (revealEls.length) {
      if ("IntersectionObserver" in window) {
        const io = new IntersectionObserver(
          (entries) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                entry.target.classList.add("in-view");
                io.unobserve(entry.target);
              }
            });
          },
          { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
        );
        revealEls.forEach((el) => io.observe(el));
      } else {
        revealEls.forEach((el) => el.classList.add("in-view"));
      }
    }

    // --- Animated stat counters ---
    const stats = document.querySelectorAll(".stat .num[data-count]");
    if (stats.length && "IntersectionObserver" in window) {
      const animateCount = (el) => {
        const target = parseFloat(el.getAttribute("data-count"));
        const suffix = el.getAttribute("data-suffix") || "";
        const prefix = el.getAttribute("data-prefix") || "";
        const decimals = el.getAttribute("data-decimals") ? parseInt(el.getAttribute("data-decimals")) : 0;
        const duration = 900;
        const start = performance.now();
        function tick(now) {
          const progress = Math.min((now - start) / duration, 1);
          const eased = 1 - Math.pow(1 - progress, 3);
          const value = target * eased;
          el.textContent = prefix + value.toFixed(decimals) + suffix;
          if (progress < 1) requestAnimationFrame(tick);
        }
        requestAnimationFrame(tick);
      };
      const statIo = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              animateCount(entry.target);
              statIo.unobserve(entry.target);
            }
          });
        },
        { threshold: 0.4 }
      );
      stats.forEach((el) => statIo.observe(el));
    }

    // --- Copy-to-clipboard (email / phone) ---
    document.querySelectorAll(".copy-btn").forEach((btn) => {
      btn.addEventListener("click", async () => {
        const value = btn.getAttribute("data-copy");
        try {
          await navigator.clipboard.writeText(value);
          btn.classList.add("copied");
          const original = btn.innerHTML;
          btn.innerHTML = "&#10003;";
          setTimeout(() => {
            btn.classList.remove("copied");
            btn.innerHTML = original;
          }, 1400);
        } catch (e) {
          /* clipboard unavailable, fail silently, mailto/tel link still works */
        }
      });
    });
  });
})();
