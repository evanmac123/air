import sanitizeHtml from 'sanitize-html';

const renderHTML = html => (
  {
    __html: sanitizeHtml(html, {
      allowedTags: [ "h3", "h4", "h5", "h6", "blockquote", "p", "a", "ul", "ol",
        "nl", "li", "b", "i", "strong", "em", "strike", "hr", "br", "div",
        "table", "thead", "caption", "tbody", "tr", "th", "td", "iframe" ],
      allowedAttributes: {
        a: [ "href", "name", "target" ],
        img: [ "src" ],
        iframe: ['width', "height", "src", "frameborder", "allow"],
      },
      selfClosing: [ "img", "br", "hr", "area", "base", "basefont", "input", "link", "meta" ],
      allowedSchemes: [ "http", "https", "mailto" ],
      allowedSchemesByTag: {},
      allowedSchemesAppliedToAttributes: [ "href", "src" ],
      allowProtocolRelative: true,
      allowedIframeHostnames: ["www.youtube.com", "player.vimeo.com", "embed.ted.com"],
    }),
  }
);

const htmlSanitizer = rawHtml => renderHTML(rawHtml);

export default htmlSanitizer;
