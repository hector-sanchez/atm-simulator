import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="form"
export default class extends Controller {
	static targets = ["cardNumber", "pin", "submitButton"];

	connect() {
		console.log("ATM Form controller connected");
		this.updateSubmitState();
	}

	// Format card number with spaces for better readability
	formatCardNumber(event) {
		let value = event.target.value.replace(/\D/g, ""); // Remove non-digits
		let formattedValue = value.replace(/(.{4})/g, "$1 ").trim(); // Add spaces every 4 digits

		if (formattedValue.length > 19) {
			// Max length with spaces: "0000 0000 0000 0000"
			formattedValue = formattedValue.slice(0, 19);
		}

		event.target.value = formattedValue;
		this.updateSubmitState();
		this.addInputFeedback(event.target, value.length >= 16);
	}

	// Format PIN to only allow digits
	formatPin(event) {
		let value = event.target.value.replace(/\D/g, ""); // Remove non-digits

		if (value.length > 4) {
			value = value.slice(0, 4); // Max 4 digits
		}

		event.target.value = value;
		this.updateSubmitState();
		this.addInputFeedback(event.target, value.length === 4);
	}

	// Add visual feedback for input completion
	addInputFeedback(input, isComplete) {
		input.style.borderColor = isComplete ? "#00b894" : "#e9ecef";

		if (isComplete) {
			input.style.boxShadow = "0 0 0 3px rgba(0, 184, 148, 0.1)";
		} else {
			input.style.boxShadow = "";
		}
	}

	// Update submit button state based on form validity
	updateSubmitState() {
		if (
			!this.hasCardNumberTarget ||
			!this.hasPinTarget ||
			!this.hasSubmitButtonTarget
		) {
			return;
		}

		const cardNumber = this.cardNumberTarget.value.replace(/\D/g, "");
		const pin = this.pinTarget.value;

		const isValid = cardNumber.length === 16 && pin.length === 4;

		this.submitButtonTarget.disabled = !isValid;

		if (isValid) {
			this.submitButtonTarget.style.opacity = "1";
			this.submitButtonTarget.style.transform = "none";
		} else {
			this.submitButtonTarget.style.opacity = "0.7";
			this.submitButtonTarget.style.transform = "none";
		}
	}

	// Show loading state when form is submitted
	showLoading(event) {
		if (!this.submitButtonTarget.disabled) {
			// Create loading animation
			this.submitButtonTarget.innerHTML = `
        <span style="display: inline-flex; align-items: center; gap: 8px;">
          <span style="width: 20px; height: 20px; border: 2px solid rgba(255,255,255,0.3); border-radius: 50%; border-top-color: white; animation: spin 1s linear infinite;"></span>
          Authenticating...
        </span>
      `;
			this.submitButtonTarget.disabled = true;

			// Add CSS animation for spinner
			if (!document.getElementById("spinner-style")) {
				const style = document.createElement("style");
				style.id = "spinner-style";
				style.textContent = `
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
        `;
				document.head.appendChild(style);
			}

			// Add loading class to form
			this.element.classList.add("loading");
		}
	}

	// Handle form submission
	submit(event) {
		console.log("Form submitted via Turbo");
	}

	// Reset form state (called when there's an error and form is re-rendered)
	reset() {
		if (this.hasSubmitButtonTarget) {
			this.submitButtonTarget.innerHTML = "Continue";
			this.submitButtonTarget.disabled = false;
			this.submitButtonTarget.style.opacity = "1";
		}
		this.element.classList.remove("loading");
		this.updateSubmitState();
	}

	// Auto-focus next field when current field is complete
	cardNumberTargetConnected() {
		this.cardNumberTarget.addEventListener("input", (event) => {
			const value = event.target.value.replace(/\D/g, "");
			if (value.length === 16) {
				this.pinTarget.focus();

				// Add subtle success animation
				event.target.style.transform = "scale(1.02)";
				setTimeout(() => {
					event.target.style.transform = "scale(1)";
				}, 150);
			}
		});

		// Add focus/blur animations
		this.cardNumberTarget.addEventListener("focus", (e) => {
			e.target.style.transform = "translateY(-2px)";
			e.target.style.boxShadow = "0 10px 25px rgba(116, 185, 255, 0.15)";
		});

		this.cardNumberTarget.addEventListener("blur", (e) => {
			e.target.style.transform = "translateY(0)";
			if (!e.target.value || e.target.value.replace(/\D/g, "").length < 16) {
				e.target.style.boxShadow = "";
			}
		});
	}

	pinTargetConnected() {
		this.pinTarget.addEventListener("input", (event) => {
			const value = event.target.value;
			if (value.length === 4) {
				// Auto-focus submit button when PIN is complete
				const cardNumber = this.cardNumberTarget.value.replace(/\D/g, "");
				if (cardNumber.length === 16) {
					setTimeout(() => {
						this.submitButtonTarget.focus();
					}, 300);

					// Add completion animation
					event.target.style.transform = "scale(1.02)";
					setTimeout(() => {
						event.target.style.transform = "scale(1)";
					}, 150);
				}
			}
		});

		// Add focus/blur animations
		this.pinTarget.addEventListener("focus", (e) => {
			e.target.style.transform = "translateY(-2px)";
			e.target.style.boxShadow = "0 10px 25px rgba(116, 185, 255, 0.15)";
		});

		this.pinTarget.addEventListener("blur", (e) => {
			e.target.style.transform = "translateY(0)";
			if (!e.target.value || e.target.value.length < 4) {
				e.target.style.boxShadow = "";
			}
		});
	}

	submitButtonTargetConnected() {
		// Add hover effects
		this.submitButtonTarget.addEventListener("mouseenter", (e) => {
			if (!e.target.disabled) {
				e.target.style.transform = "translateY(-2px)";
			}
		});

		this.submitButtonTarget.addEventListener("mouseleave", (e) => {
			if (!e.target.disabled) {
				e.target.style.transform = "translateY(0)";
			}
		});
	}
}
