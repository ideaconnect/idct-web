document.getElementById('yr').textContent = new Date().getFullYear();

// ── Thank-you banner ────────────────────────────────
if (window.location.search.includes('thank-you')) {
  var banner = document.getElementById('thank-you-banner');
  if (banner) {
    banner.removeAttribute('hidden');
    banner.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
}

// ── Form validation ───────────────────────────────────────
(function () {
  const form    = document.getElementById('contact-form');
  if (!form) return;

  const btn     = document.getElementById('btn-submit');
  const consent = document.getElementById('f-consent');
  let captchaSolved = false;

  // Exposed globally for reCAPTCHA callbacks
  window.onCaptchaSuccess = function () { captchaSolved = true;  updateSubmit(); };
  window.onCaptchaExpired = function () { captchaSolved = false; updateSubmit(); };

  const rules = {
    'f-name': function (v) {
      if (!v)          return 'Name is required.';
      if (v.length < 2)   return 'Must be at least 2 characters.';
      if (v.length > 250) return 'Must be 250 characters or fewer.';
      return null;
    },
    'f-email': function (v) {
      if (!v)          return 'Email is required.';
      if (v.length > 250) return 'Must be 250 characters or fewer.';
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) return 'Enter a valid email address.';
      return null;
    },
    'f-subject': function (v) {
      if (!v)          return null; // optional
      if (v.length < 2)   return 'Must be at least 2 characters.';
      if (v.length > 250) return 'Must be 250 characters or fewer.';
      return null;
    },
    'f-message': function (v) {
      if (!v)           return 'Message is required.';
      if (v.length < 5)    return 'Must be at least 5 characters.';
      if (v.length > 5000) return 'Must be 5000 characters or fewer.';
      return null;
    }
  };

  function validateField(el) {
    var rule  = rules[el.id];
    if (!rule) return true;
    var error = rule(el.value.trim());
    var group = el.closest('.field-group');
    var span  = group && group.querySelector('.field-error');
    if (group) group.classList.toggle('invalid', !!error);
    if (span)  span.textContent = error || '';
    return !error;
  }

  function allFieldsValid() {
    return Object.keys(rules).every(function (id) {
      var el = document.getElementById(id);
      return el && rules[id](el.value.trim()) === null;
    });
  }

  function updateSubmit() {
    btn.disabled = !(allFieldsValid() && consent.checked && captchaSolved);
  }

  Object.keys(rules).forEach(function (id) {
    var el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('blur',  function () { validateField(el); updateSubmit(); });
    el.addEventListener('input', function () { validateField(el); updateSubmit(); });
  });

  consent.addEventListener('change', updateSubmit);

  form.addEventListener('submit', function (e) {
    var allOk = Object.keys(rules).every(function (id) {
      return validateField(document.getElementById(id));
    });
    if (!allOk || !consent.checked || !captchaSolved) e.preventDefault();
  });
}());
