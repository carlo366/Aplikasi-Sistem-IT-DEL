<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RequestizinBermalam extends Model
{
    use HasFactory;

    protected $table = 'requestizin_bermalams';
    protected $fillable = ['user_id', 'approver_role', 'approver_id', 'tujuan', 'reason', 'start_date', 'end_date', 'status'];

    //  public function user()
    // {
    //     return $this->belongsTo(User::class, 'user_id', 'id');
    // }
}

