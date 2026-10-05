module.exports = (config) => {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular/build'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage'),
      require('@angular/build/plugins/karma'),
    ],
    client: { clearContext: false },
    reporters: ['progress', 'kjhtml'],
    browsers: ['ChromeHeadless'],
    restartOnFileChange: true,
  });
};
