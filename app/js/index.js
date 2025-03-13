document.addEventListener("DOMContentLoaded", function() {
    var defaultTab = document.getElementById("defaultOpen");
    if (defaultTab) {
        defaultTab.click()
    } else {
        var firstTab = document.querySelector(".tablink");
        if (firstTab) {
            firstTab.click()
        }
    }
    var defaultInnerTab = document.querySelector(".innertabcontent");
    if (defaultInnerTab) {
        defaultInnerTab.classList.add("active");
        defaultInnerTab.style.display = "block";
        var innerTabId = defaultInnerTab.id;
        var innerTabBtn = document.querySelector(`.tablink[onclick*="${innerTabId}"]`);
        if (innerTabBtn) {
            innerTabBtn.classList.add("active")
        }
    }
    
    const aboutButton = document.getElementById('about_btn');
    if (aboutButton) {
        aboutButton.addEventListener('click', function() {
            // Toggle the 'active' class on the about button
            aboutButton.classList.toggle('active');
            
            // Optionally, add more functionality, such as changing the icon or other actions
            if (aboutButton.classList.contains('active')) {
                // You can change the content or icon here when the button is active
                console.log("About button is active");
            } else {
                console.log("About button is inactive");
            }
        });
    }
});

function resizeCharts() {
    console.log("Resizing charts");
    if (window.Plotly) {
        var plots = document.querySelectorAll('.js-plotly-plot');
        for (var i = 0; i < plots.length; i++) {
            window.Plotly.Plots.resize(plots[i])
        }
    }
    if (window.HTMLWidgets && window.HTMLWidgets.staticRender) {
        window.HTMLWidgets.staticRender()
    }
    if (window.dispatchEvent) {
        window.dispatchEvent(new Event('resize'))
    }
}

function openTab(evt, tabName) {
    console.log("Opening tab:", tabName);
    var tabcontent = document.getElementsByClassName("tabcontent");
    for (var i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
        tabcontent[i].classList.remove("active")
    }
    var tablinks = document.getElementsByClassName("tablink");
    for (var i = 0; i < tablinks.length; i++) {
        tablinks[i].classList.remove("active")
    }
    var currentTab = document.getElementById(tabName);
    if (currentTab) {
        currentTab.style.display = "block";
        currentTab.classList.add("active");
        evt.currentTarget.classList.add("active");
        if (window.Shiny && window.Shiny.unbindAll && window.Shiny.bindAll) {
            window.Shiny.unbindAll(currentTab);
            window.Shiny.bindAll(currentTab)
        }
        var chartContainers = currentTab.querySelectorAll(".card-body");
        for (var i = 0; i < chartContainers.length; i++) {
            chartContainers[i].style.display = "block";
            chartContainers[i].style.visibility = "visible"
        }
        var shinyOutputs = currentTab.querySelectorAll(".shiny-plot-output, .html-widget-output");
        for (var i = 0; i < shinyOutputs.length; i++) {
            shinyOutputs[i].style.display = "block";
            shinyOutputs[i].style.visibility = "visible"
        }
        setTimeout(function() {
            resizeCharts()
        }, 300)
    }
}

function openInnerTab(evt, tabName) {
    console.log("Opening inner tab:", tabName);
    var parentTab = evt.currentTarget.closest(".tabcontent");
    if (!parentTab) return;
    var innerTabs = parentTab.getElementsByClassName("innertabcontent");
    for (var i = 0; i < innerTabs.length; i++) {
        innerTabs[i].style.display = "none";
        innerTabs[i].classList.remove("active")
    }
    var tablinks = parentTab.querySelectorAll(".tabset .tablink");
    for (var i = 0; i < tablinks.length; i++) {
        tablinks[i].classList.remove("active")
    }
    var currentInnerTab = document.getElementById(tabName);
    if (currentInnerTab) {
        currentInnerTab.style.display = "block";
        currentInnerTab.classList.add("active");
        evt.currentTarget.classList.add("active");
        var shinyOutputs = currentInnerTab.querySelectorAll(".shiny-plot-output, .html-widget-output");
        for (var i = 0; i < shinyOutputs.length; i++) {
            shinyOutputs[i].style.display = "block";
            shinyOutputs[i].style.visibility = "visible"
        }
        setTimeout(function() {
            resizeCharts()
        }, 300)
    }
}

// Function to toggle the sidebar's visibility (open/close)
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    const sidebarToggleIcon = document.getElementById("sidebarToggleIcon");

    // Close the sidebar
    sidebar.classList.add('sidebar-collapsed');

    // Change the sidebar button icon depending on the state of the sidebar
    sidebarToggleIcon.classList.remove("fa-bars");
    sidebarToggleIcon.classList.add("fa-bars"); // Change to an arrow icon when collapsed

    // Call resizeCharts after a short delay (to account for the transition)
    setTimeout(function() {
        resizeCharts();
    }, 300);
}

// Function to open the sidebar when the "Open Sidebar" button is clicked
function openSidebar() {
    const sidebar = document.querySelector('.sidebar');
    const sidebarToggleIcon = document.getElementById("sidebarToggleIcon");

    // Open the sidebar
    sidebar.classList.remove('sidebar-collapsed');

    // Change the sidebar button icon to show "close" icon when the sidebar is open
    sidebarToggleIcon.classList.remove("fa-bars");
    sidebarToggleIcon.classList.add("fa-bars"); // Change to bars icon when expanded
}


const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
        if (mutation.addedNodes && mutation.addedNodes.length > 0) {
            for (var i = 0; i < mutation.addedNodes.length; i++) {
                var node = mutation.addedNodes[i];
                if (node.classList && (node.classList.contains('shiny-plot-output') || node.classList.contains('html-widget-output'))) {
                    console.log("New Shiny output detected:", node);
                    var parentTab = node.closest('.tabcontent');
                    if (parentTab && parentTab.classList.contains('active')) {
                        node.style.display = "block";
                        node.style.visibility = "visible";
                        setTimeout(function() {
                            resizeCharts()
                        }, 300)
                    }
                }
            }
        }
    })
});
observer.observe(document.body, {
    childList: !0,
    subtree: !0
})


// Function to toggle between normal size and expanded size with blur effect
function toggleFullscreen() {
    // Find the closest card container for the button that was clicked
    var button = event.currentTarget; // Get the button that was clicked
    var card = button.closest('.card'); // Get the closest .card container

    // Check if the card exists
    if (!card) return;

    // Toggle the expanded class to make the card expand/collapse
    card.classList.toggle('expanded'); // Add/remove the 'expanded' class

    // Optional: If you want to add a blur effect to other elements, you can do this:
    // document.body.classList.toggle('blurred'); // You can add a 'blurred' class to the body for a blur effect

    // If you want the fullscreen effect on the card itself, you can also use:
    if (!document.fullscreenElement) {
        if (card.requestFullscreen) {
            card.requestFullscreen();
        } else if (card.mozRequestFullScreen) { // Firefox
            card.mozRequestFullScreen();
        } else if (card.webkitRequestFullscreen) { // Chrome, Safari, Opera
            card.webkitRequestFullscreen();
        } else if (card.msRequestFullscreen) { // IE/Edge
            card.msRequestFullscreen();
        }
    } else {
        // Exit fullscreen if it's already active
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.mozCancelFullScreen) { // Firefox
            document.mozCancelFullScreen();
        } else if (document.webkitExitFullscreen) { // Chrome, Safari, Opera
            document.webkitExitFullscreen();
        } else if (document.msExitFullscreen) { // IE/Edge
            document.msExitFullscreen();
        }
    }
}
