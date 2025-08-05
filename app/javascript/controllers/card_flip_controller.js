import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["flipper"];

	connect() {
		// Initialize the flipper state
		this.flipped = false;
	}

	toggle() {
		this.flipped = !this.flipped;

		if (this.flipped) {
			this.flipperTarget.classList.add("flipped");
		} else {
			this.flipperTarget.classList.remove("flipped");
		}
	}
}
