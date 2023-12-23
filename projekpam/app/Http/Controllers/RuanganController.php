<?php

namespace App\Http\Controllers;

use App\Models\ruangan;
use Illuminate\Http\Request;

class RuanganController extends Controller
{
    public function index()
    {
        $rooms = ruangan::all();

        return response()->json(['Ruangan' => $rooms], 200);
    }
}
