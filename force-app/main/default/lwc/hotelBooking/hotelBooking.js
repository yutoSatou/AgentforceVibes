import { LightningElement, track } from 'lwc';

export default class HotelBooking extends LightningElement {
    @track selectedRoomType = '';
    @track selectedGuests = '1';
    @track isEnrolling = false;

    roomTypes = [
        { label: 'Standard Room', value: 'standard' },
        { label: 'Deluxe Room', value: 'deluxe' },
        { label: 'Executive Suite', value: 'executive' },
        { label: 'Presidential Suite', value: 'presidential' }
    ];

    guestOptions = [
        { label: '1 Guest', value: '1' },
        { label: '2 Guests', value: '2' },
        { label: '3 Guests', value: '3' },
        { label: '4 Guests', value: '4' }
    ];

    handleBookNow() {
        // Scroll to booking section
        this.template.querySelector('.booking-section').scrollIntoView({ behavior: 'smooth' });
    }

    handleViewRooms() {
        // Implement room viewing functionality
        console.log('View rooms clicked');
    }

    handleChatWithRoomie() {
        // Implement chat with Roomie functionality
        console.log('Chat with Roomie clicked');
    }

    handleRoomTypeChange(event) {
        this.selectedRoomType = event.detail.value;
    }

    handleGuestsChange(event) {
        this.selectedGuests = event.detail.value;
    }

    handleCheckAvailability() {
        // Implement availability check
        console.log('Checking availability for:', {
            roomType: this.selectedRoomType,
            guests: this.selectedGuests
        });
    }
}