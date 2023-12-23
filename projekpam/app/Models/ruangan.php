<?php

namespace App\Models;

use App\Http\Controllers\AdminBookingRuanganController;
use App\Http\Controllers\BookingRuanganController;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ruangan extends Model
{
    use HasFactory;

    use HasFactory;
    protected $table = 'ruangan';

    protected $fillable = [
        'NamaRuangan',
    ];


    public function bookings()
    {
        return $this->hasMany(BookingRuanganController::class, 'room_id');
    }
}
