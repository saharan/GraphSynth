package app.ui;

enum PointerPolicy {
	/**
	 * events are sent when a pointer is on the element, regardless of
	 * if and where the pointer is pressed.
	 */
	Free;

	/**
	 * if a pointer is down outside the element, events are not sent
	 * until the pointer is up.
	 */
	Lock;

	/**
	 * same as `Lock`, except all other `Free` elements behaves as
	 * `Lock` while a pointer is down on the element.
	 */
	Exclusive;
}
