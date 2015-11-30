import 'package:chrome/chrome_ext.dart' as chrome;

void main() {
  chrome.TabsQueryParams q =
      new chrome.TabsQueryParams(active: true, currentWindow: true);
  chrome.tabs.query(q).then((tabs) {
    chrome.pageAction.show(tabs[0].id);
  });

  chrome.tabs.onSelectionChanged.listen((chrome.OnSelectionChangedEvent event) {
    chrome.pageAction.show(event.tabId);
  });
}
