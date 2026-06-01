// Vote functionality
(function() {
    'use strict';
    
    // Vote option selection
    window.selectVoteOption = (optionId) => {
        const radio = document.getElementById('option' + optionId);
        if (radio) {
            radio.checked = true;
            // Update visual selection
            document.querySelectorAll('.option-card').forEach(card => {
                card.classList.remove('selected');
            });
            const selectedCard = radio.closest('.option-card');
            if (selectedCard) {
                selectedCard.classList.add('selected');
            }
        }
    };
    
    // Auto-select option on card click
    const initOptionCardSelection = () => {
        document.querySelectorAll('.option-card').forEach(card => {
            card.addEventListener('click', function(e) {
                if (e.target.type !== 'radio') {
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio) {
                        radio.checked = true;
                        document.querySelectorAll('.option-card').forEach(c => {
                            c.classList.remove('selected');
                        });
                        this.classList.add('selected');
                    }
                }
            });
        });
    };
    
    // Confirm delete
    window.confirmDelete = (voteId) => {
        return confirm(`Are you sure you want to delete vote "${voteId}"? This action cannot be undone.`);
    };
    
    // Confirm publish
    window.confirmPublish = () => {
        return confirm('Are you ready to publish this vote? Once published, you cannot edit it.');
    };
    
    // Report issue (for error pages)
    window.reportIssue = (event) => {
        event.preventDefault();
        const description = document.getElementById('reportDescription');
        if (description && description.value.trim()) {
            console.log('Error report:', description.value);
            alert('Thank you for your report. Our team will investigate the issue.');
            description.value = '';
        } else if (description) {
            alert('Please describe what you were trying to do.');
        }
    };
    
    // Search site (for 404 page)
    window.searchSite = () => {
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            const searchTerm = searchInput.value.trim();
            if (searchTerm) {
                alert('Search functionality would look for: ' + searchTerm);
            }
        }
    };
    
    // Reload page with cache clear
    window.clearCacheAndReload = () => {
        window.location.reload(true);
    };
    
    // Initialize on page load
    document.addEventListener('DOMContentLoaded', () => {
        initOptionCardSelection();
        
        // Enter key search for 404 page
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    window.searchSite();
                }
            });
        }
    });
})();