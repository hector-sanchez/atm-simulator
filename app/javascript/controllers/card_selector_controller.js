import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["tab", "card"];
	static values = { active: Number };

	connect() {
		this.showActiveCard();
		// Add viewing indicator to the initially active tab (first one)
		const activeTab = this.tabTargets[this.activeValue];
		if (activeTab && !activeTab.querySelector(".current-indicator")) {
			const selectedSpan = document.createElement("span");
			selectedSpan.className = "selected-indicator";
			selectedSpan.textContent = "VIEWING";
			activeTab.querySelector(".tab-info").appendChild(selectedSpan);
		}
	}

	selectCard(event) {
		const selectedIndex = parseInt(event.currentTarget.dataset.cardIndex);

		// Update active index
		this.activeValue = selectedIndex;

		// Update tab states and selected indicators
		this.tabTargets.forEach((tab, index) => {
			if (index === selectedIndex) {
				tab.classList.add("active");
				// Add selected indicator if not already current
				if (!tab.querySelector(".current-indicator")) {
					const selectedSpan =
						tab.querySelector(".selected-indicator") ||
						document.createElement("span");
					selectedSpan.className = "selected-indicator";
					selectedSpan.textContent = "VIEWING";
					if (!tab.querySelector(".selected-indicator")) {
						tab.querySelector(".tab-info").appendChild(selectedSpan);
					}
				}
			} else {
				tab.classList.remove("active");
				// Remove selected indicator
				const selectedSpan = tab.querySelector(".selected-indicator");
				if (selectedSpan) {
					selectedSpan.remove();
				}
			}
		});

		// Show selected card with smooth transition
		this.showActiveCard();
	}

	showActiveCard() {
		this.cardTargets.forEach((card, index) => {
			if (index === this.activeValue) {
				card.classList.add("active");
			} else {
				card.classList.remove("active");
			}
		});
	}

	activeValueChanged() {
		this.showActiveCard();
	}
}
