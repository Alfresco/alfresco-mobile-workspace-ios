/* Copyright 2016 Mozilla Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

"use strict";

if (!pdfjsLib.getDocument || !pdfjsViewer.PDFViewer) {
  alert("Please build the pdfjs-dist library using\n `gulp dist-install`");
}

var USE_ONLY_CSS_ZOOM = true;
var TEXT_LAYER_MODE = 1; // ENABLED
var MAX_IMAGE_SIZE = 4096 * 4096;

var DEFAULT_URL = "SAMPLE.PDF";
var DEFAULT_SCALE_DELTA = 1;
var MAX_SCALE = 3.0;
var DEFAULT_SCALE_VALUE = "auto";

var PDFViewerApplication = {
  pdfLoadingTask: null,
  pdfDocument: null,
  pdfViewer: null,
  pdfHistory: null,
  pdfLinkService: null,
  eventBus: null,
  findController: null,
  initialScale: 1.0,
  maxScale: MAX_SCALE,
  onPassword: null,

  /**
   * Opens PDF document specified by URL.
   * @returns {Promise} - Returns the promise, which is resolved when document
   *                      is opened.
   */
  open: function (params) {
    if (this.pdfLoadingTask) {
      // We need to destroy already opened document
      return this.close().then(
        function () {
          // ... and repeat the open() call.
          return this.open(params);
        }.bind(this)
      );
    }

    var url = params.url;
    var self = this;
    this.setTitleUsingUrl(url);

    // Loading document.
    var loadingTask = pdfjsLib.getDocument({
      url: url,
      maxImageSize: MAX_IMAGE_SIZE
    });
    this.pdfLoadingTask = loadingTask;

    loadingTask.onProgress = function (progressData) {
      self.progress(progressData.loaded / progressData.total);
    };

    loadingTask.onPassword = function (callback, reason) {
      self.onPassword = callback;
      try {
        if (reason == 1) {
          webkit.messageHandlers.pdfAction.postMessage("showPasswordPrompt");
        } else {
          webkit.messageHandlers.pdfAction.postMessage("invalidPasswordPrompt");
        }
      } catch(err) {
        console.log('The native context does not exist yet');
      }
    };

    return loadingTask.promise.then(
      function (pdfDocument) {
        // Document loaded, specifying document for the viewer.
        self.pdfDocument = pdfDocument;
        self.pdfViewer.setDocument(pdfDocument);
        self.pdfLinkService.setDocument(pdfDocument);
        self.pdfHistory.initialize({ fingerprint: pdfDocument.fingerprint });

        self.loadingBar.hide();
        self.setTitleUsingMetadata(pdfDocument);
      },
      function (exception) {
        var message = exception && exception.message;
        var l10n = self.l10n;
        var loadingErrorMessage;

        if (exception instanceof pdfjsLib.InvalidPDFException) {
          // change error message also for other builds
          loadingErrorMessage = l10n.get(
            "invalid_file_error",
            null,
            "Invalid or corrupted PDF file."
          );
        } else if (exception instanceof pdfjsLib.MissingPDFException) {
          // special message for missing PDFs
          loadingErrorMessage = l10n.get(
            "missing_file_error",
            null,
            "Missing PDF file."
          );
        } else if (exception instanceof pdfjsLib.UnexpectedResponseException) {
          loadingErrorMessage = l10n.get(
            "unexpected_response_error",
            null,
            "Unexpected server response."
          );
        } else {
          loadingErrorMessage = l10n.get(
            "loading_error",
            null,
            "An error occurred while loading the PDF."
          );
        }

        loadingErrorMessage.then(function (msg) {
          self.error(msg, { message: message });
        });
        self.loadingBar.hide();
      }
    );
  },

  /**
   * Closes opened PDF document.
   * @returns {Promise} - Returns the promise, which is resolved when all
   *                      destruction is completed.
   */
  close: function () {
    var errorWrapper = document.getElementById("errorWrapper");
    errorWrapper.setAttribute("hidden", "true");

    if (!this.pdfLoadingTask) {
      return Promise.resolve();
    }

    var promise = this.pdfLoadingTask.destroy();
    this.pdfLoadingTask = null;

    if (this.pdfDocument) {
      this.pdfDocument = null;

      this.pdfViewer.setDocument(null);
      this.pdfLinkService.setDocument(null, null);

      if (this.pdfHistory) {
        this.pdfHistory.reset();
      }
    }

    return promise;
  },

  get loadingBar() {
    var bar = new pdfjsViewer.ProgressBar("#loadingBar", {});

    return pdfjsLib.shadow(this, "loadingBar", bar);
  },

  setTitleUsingUrl: function pdfViewSetTitleUsingUrl(url) {
    this.url = url;
    var title = pdfjsLib.getFilenameFromUrl(url) || url;
    try {
      title = decodeURIComponent(title);
    } catch (e) {
      // decodeURIComponent may throw URIError,
      // fall back to using the unprocessed url in that case
    }
    this.setTitle(title);
  },

  setTitleUsingMetadata: function (pdfDocument) {
    var self = this;
    pdfDocument.getMetadata().then(function (data) {
      var info = data.info,
        metadata = data.metadata;
      self.documentInfo = info;
      self.metadata = metadata;

      // Provides some basic debug information
      console.log(
        "PDF " +
          pdfDocument.fingerprint +
          " [" +
          info.PDFFormatVersion +
          " " +
          (info.Producer || "-").trim() +
          " / " +
          (info.Creator || "-").trim() +
          "]" +
          " (PDF.js: " +
          (pdfjsLib.version || "-") +
          ")"
      );

      var pdfTitle;
      if (metadata && metadata.has("dc:title")) {
        var title = metadata.get("dc:title");
        // Ghostscript sometimes returns 'Untitled', so prevent setting the
        // title to 'Untitled.
        if (title !== "Untitled") {
          pdfTitle = title;
        }
      }

      if (!pdfTitle && info && info.Title) {
        pdfTitle = info.Title;
      }

      if (pdfTitle) {
        self.setTitle(pdfTitle + " - " + document.title);
      }
    });
  },

  setTitle: function pdfViewSetTitle(title) {
    document.title = title;
    // document.getElementById("title").textContent = title;
  },

  error: function pdfViewError(message, moreInfo) {
    var l10n = this.l10n;
    var moreInfoText = [
      l10n.get(
        "error_version_info",
        { version: pdfjsLib.version || "?", build: pdfjsLib.build || "?" },
        "PDF.js v{{version}} (build: {{build}})"
      ),
    ];

    if (moreInfo) {
      moreInfoText.push(
        l10n.get(
          "error_message",
          { message: moreInfo.message },
          "Message: {{message}}"
        )
      );
      if (moreInfo.stack) {
        moreInfoText.push(
          l10n.get("error_stack", { stack: moreInfo.stack }, "Stack: {{stack}}")
        );
      } else {
        if (moreInfo.filename) {
          moreInfoText.push(
            l10n.get(
              "error_file",
              { file: moreInfo.filename },
              "File: {{file}}"
            )
          );
        }
        if (moreInfo.lineNumber) {
          moreInfoText.push(
            l10n.get(
              "error_line",
              { line: moreInfo.lineNumber },
              "Line: {{line}}"
            )
          );
        }
      }
    }

    var errorWrapper = document.getElementById("errorWrapper");
    errorWrapper.removeAttribute("hidden");

    var errorMessage = document.getElementById("errorMessage");
    errorMessage.textContent = message;

    var closeButton = document.getElementById("errorClose");
    closeButton.onclick = function () {
      errorWrapper.setAttribute("hidden", "true");
    };

    var errorMoreInfo = document.getElementById("errorMoreInfo");
    var moreInfoButton = document.getElementById("errorShowMore");
    var lessInfoButton = document.getElementById("errorShowLess");
    moreInfoButton.onclick = function () {
      errorMoreInfo.removeAttribute("hidden");
      moreInfoButton.setAttribute("hidden", "true");
      lessInfoButton.removeAttribute("hidden");
      errorMoreInfo.style.height = errorMoreInfo.scrollHeight + "px";
    };
    lessInfoButton.onclick = function () {
      errorMoreInfo.setAttribute("hidden", "true");
      moreInfoButton.removeAttribute("hidden");
      lessInfoButton.setAttribute("hidden", "true");
    };
    moreInfoButton.removeAttribute("hidden");
    lessInfoButton.setAttribute("hidden", "true");
    Promise.all(moreInfoText).then(function (parts) {
      errorMoreInfo.value = parts.join("\n");
    });
  },

  progress: function pdfViewProgress(level) {
    var percent = Math.round(level * 100);
    // Updating the bar if value increases.
    if (percent > this.loadingBar.percent || isNaN(percent)) {
      this.loadingBar.percent = percent;
    }
  },

  get pagesCount() {
    return this.pdfDocument.numPages;
  },

  get page() {
    return this.pdfViewer.currentPageNumber;
  },

  set page(val) {
    this.pdfViewer.currentPageNumber = val;
  },

  initUI: function pdfViewInitUI() {
    var self = this;
    var eventBus = new pdfjsViewer.EventBus();
    this.eventBus = eventBus;

    var linkService = new pdfjsViewer.PDFLinkService({
      eventBus: eventBus,
    });
    this.pdfLinkService = linkService;

    this.l10n = pdfjsViewer.NullL10n;

    this.findController = new pdfjsViewer.PDFFindController({
      linkService: linkService,
      eventBus: eventBus,
    });

    var container = document.getElementById("viewerContainer");
    var pdfViewer = new pdfjsViewer.PDFViewer({
      container: container,
      eventBus: eventBus,
      linkService: linkService,
      l10n: this.l10n,
      useOnlyCssZoom: USE_ONLY_CSS_ZOOM,
      textLayerMode: TEXT_LAYER_MODE,
      findController: this.findController,
    });
    this.pdfViewer = pdfViewer;
    linkService.setViewer(pdfViewer);

    this.pdfHistory = new pdfjsViewer.PDFHistory({
      eventBus: eventBus,
      linkService: linkService,
    });
    linkService.setHistory(this.pdfHistory);

    eventBus.on("pagesinit", function () {
      // We can use pdfViewer now, e.g. let's change default scale.
      pdfViewer.currentScaleValue = DEFAULT_SCALE_VALUE;
      PDFViewerApplication.initialScale = pdfViewer.currentScale;

      if (self.pdfDocument.numPages == 1) {
           container.classList.add('singlePage');
      }

//      pdfViewer.findController.executeCommand("find", {
//        caseSensitive: false,
//        findPrevious: undefined,
//        highlightAll: true,
//        phraseSearch: true,
//        query: "earth"
//      });
    });

    var pageIndicator = document.getElementById("pageIndicator");
    var padeIndicatorTimeout;
    eventBus.on("pagechanging", function (evt) {
      const page = evt.pageNumber;
      const total = self.pdfDocument.numPages;
      pageIndicator.textContent = `${page} of ${total}`;

      if (!pageIndicator.classList.contains('fadeIn')) {
        pageIndicator.classList.add('fadeIn');
      }

      clearTimeout(padeIndicatorTimeout);
      padeIndicatorTimeout = setTimeout(function() {
        pageIndicator.classList.remove('fadeIn');
      }, 2000);
    });
  },
};

document.addEventListener(
  "DOMContentLoaded",
  function () {
    PDFViewerApplication.initUI();
  },
  true
);

(function animationStartedClosure() {
  // The offsetParent is not set until the PDF.js iframe or object is visible.
  // Waiting for first animation.
  PDFViewerApplication.animationStartedPromise = new Promise(function (
    resolve
  ) {
    window.requestAnimationFrame(resolve);
  });
})();

// We need to delay opening until all HTML is loaded.
PDFViewerApplication.animationStartedPromise.then(function () {
  PDFViewerApplication.open({
    url: DEFAULT_URL,
  });
});
