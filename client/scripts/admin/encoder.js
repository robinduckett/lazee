(function() {
    var template = {};
    
    function updateJobs() {    
        var tasks = [];
    
        _.each(jobs, function(job) {
            var tasklistitem = template.render('tasklistitem', job);
            
            tasks.push(tasklistitem);
        });
    
        $('#jobs').html(template.render('tasklist', {
            tasks: tasks
        }));
    }


    $(function() {
        window.jobs = JSON.parse($('#x_jobs').html());
    
        template = new Template();
        
        template.add("tasklist", "admin/tasklist.html");
        template.add("tasklistitem", "admin/tasklistitem.html");

        template.load(function() {  
            updateJobs();      
            
            setInterval(function() {
                $.getJSON('/admin/encoder/jobs', function(result, xhr) {
                    window.jobs = result;
            
                    updateJobs();
                });
            }, 2000);
        });
    });
})();