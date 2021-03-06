function Template(templateDir) {
    this.templateDir = templateDir || "templates";
    this.templates = [];
    this.rendered = {};
}

Template.prototype.load = function(complete) {
    var responses = 0;
    var self = this;

    if (this.templates.length > 0) {
        this.templates.forEach(function(template) {
            console.log("Loading " + self.templateDir + '/' + template.path);

            $.ajax({
                url: '/' + self.templateDir + '/' + template.path,
                dataType: 'html',
                success: function(source) {
                    self.rendered[template.name] = _.template(source);
                },

                error: function() {
                    console.error("Unable to load " + template.path);
                },

                complete: function() {
                    responses++;

                    if (responses == self.templates.length) {
                        if (complete instanceof Function) {
                            complete();
                        }
                    }
                }
            });
        });
    } else {
        if (complete instanceof Function) {
            complete();
        }
    }
};

Template.prototype.add = function(name, path) {
    this.templates.push({
        name: name,
        path: path
    });

    return this;
};

Template.prototype.render = function(template, options) {
    return this.rendered[template](options);
}