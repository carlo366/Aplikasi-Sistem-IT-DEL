<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Kaos;
use App\Models\Pemesanan;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Models\User;


class PemesananController extends Controller
{
    public function index()
    {
        $kaos = Pemesanan::all();

        return response()->json(['Pemesanan' => $kaos], 200);
    }

    public function store(Request $request)
    {
        $rules = [
            'kaos_id' => 'required|exists:kaos,id',
            'jumlah_pesanan' => 'required|integer|min:1',
            'jenis_pembayaran' => 'required',
            'jumlah_nominal' => 'required|int|min:1',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        $kaos = Kaos::find($request->kaos_id);

        if (!$kaos) {
            return response()->json(['error' => 'Kaos dengan ID yang diminta tidak ditemukan.'], 404);
        }

        $total_harga = $kaos->harga * $request->jumlah_pesanan;

        if ($request->jumlah_nominal != $total_harga) {
            return response()->json(['error' => 'Jumlah nominal pembayaran tidak sesuai dengan total harga.'], 400);
        }

        $pemesanan = Pemesanan::create([
            'user_id' => auth()->user()->id,
            'kaos_id' => $request->kaos_id,
            'jumlah_pesanan' => $request->jumlah_pesanan,
            'total_harga' => $total_harga,
        ]);

        return response()->json(['Pemesanan' => $pemesanan], 201); // 201 Created status code
    }
    public function indexsemua()
    {
        $rooms = Kaos::all();

        return response()->json(['Kaos' => $rooms], 200);
    }
}
