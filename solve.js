// CTF Solver - Decrypt Breakout Game Levels
// Run with: node solver.js

const zlib = require('zlib');

// The encrypted next level data from the obfuscated code
// This is the huge base64 blob from the 'nextLevelData' field
const ENCRYPTED_DATA = `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BvyXCLDlogvAsujmmuuVttHyufvIqNfhosTRyK8Yvufer0nTuhHnn09wtuTdrtLXAer0vZbSmJLvqtHomdHKtxiZDZCRm014ugHWtufUrxi0meHoueS0zuv1q2jumK9SsgrLuxjAwMvrz293EdvHBZjjyKnfyvPruI81mgfMr05QwNLwz3DuDg53mK5ws1HbDZbfmK5SvufZu2y0zMmYCKu1Dg1Tt2nXr3zoyvHOrNbQm3a3wdLvAtHhu05nz3aVkZz3EvD2uNDKyJjky0fAuMvKzMi5mMe5thLRtwvgBNbbvfC2tLLxnKHPm1Dbnw03yJvKmw1htfPcq3PfBg85n3DSmg9el2y4DfPpmxPSBeWWn3b4EMv0mLLLCZbPzxfqm2HUnMD2tKvvvwrZz2DRns9uBvjOCfDXBLfprZyZt3L6AtbrCxnvswDSDu1MrfP0vhG4yxbck2jQovL1zfDqAK90veHZus9OnMLeA3mYndrRB2jdBtrUmvLNtuPnyw9nsZj4swzVn2vPvJn2lZf6sKnxk3bereXAq3jov3L6DZvAywnoBI9OzeP3mfbcvM9js0jhrg9LrtzfuhnNotm2l3HSuu9Ml2y0l0zPALDpA1q2z0LzENvqzg1xtgftv0Pxmhf1vwi5meq3BtDrDgrewNfztLPMzNLgrdCXl1DItJjIveGVCevqmtq1DsT6nM9WzefTnNHJzg9mrMnzA3bJzeCYBdfwuumZwKm4yJffv2jZyJLyAfOWuNLKCZnoouvpwKTxCJnYrgXxBJLRtJnVA09RzLC0uMX0rNG2r3L0AvC4oxPuntvvmuzXEffsogHduZuRm2PUvKXwy0W3EgHxk3rzseyRreLsy3LSrdrWBtzluJHKqwrKug5nwejNDvbVwgzZBtjps3a5odvps28XnxHetxvmuvLcEui0EvDMzuPjCMC1t2nQnwTKDgP0mvDhBMHpEhbizvPyDdrLAe9Wv3nXDvzrtKi0owT2tdruneDpuuX3z3bLEgfpu0j4z29Rrgz5A3HlCZbZmNrwm0zQB09qsc8YA3LAsuPeA295qI9sEdfbs3LbD3i1EfHqngXOndD1sMngq2jrtdrgCvL1vLP1nLvvz1nwwhzhs0rmrKrVv3jtyLr1BM96zhz2vxeRvMD3EwWRqZmXk2frqvH3nM0RBxztng4Wy2TzEKfHqJrHAwi2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`.replace(/\s+/g, "");
const HIT_VALUES = [
    0xe31329f4,
    0x9bcfbc46,
    0x03ffe057,
    0x9a1b1dca,
    0x66fa61da,
    0xf6f2f5c5,
    0x74074c6c,
    0xa37be577,
    0x58162ae2,
    0x02113426
  ];
  
  // Grid size
  const ROWS = 10;
  const COLS = 10;
  
  // ===================== RC4 =====================
  
  function rc4(keyHex, data) {
    const key = Buffer.from(keyHex, "hex"); // correct: binary key
    const S = new Uint8Array(256);
  
    for (let i = 0; i < 256; i++) S[i] = i;
  
    let j = 0;
    for (let i = 0; i < 256; i++) {
      j = (j + S[i] + key[i % key.length]) & 0xff;
      [S[i], S[j]] = [S[j], S[i]];
    }
  
    let i = 0;
    j = 0;
    const out = Buffer.alloc(data.length);
    for (let k = 0; k < data.length; k++) {
      i = (i + 1) & 0xff;
      j = (j + S[i]) & 0xff;
      [S[i], S[j]] = [S[j], S[i]];
      out[k] = data[k] ^ S[(S[i] + S[j]) & 0xff];
    }
    return out;
  }
  
  // ===================== HASH =====================
  
  function computeKey(order) {
    let acc1 = 0x13572468;
    let acc2 = 0x24681357;
    let acc3 = ((ROWS << 16) ^ COLS) >>> 0;
  
    for (const v0 of order) {
      const v = v0 >>> 0;
      const rot = ((v << 7) | (v >>> 25)) >>> 0;
      acc1 = (acc1 + v) >>> 0;
      acc2 = (acc2 + rot) >>> 0;
      acc3 = (acc3 + (v ^ 0x9e3779b9)) >>> 0;
    }
  
    return [acc1, acc2, acc3]
      .map(v => v.toString(16).padStart(8, "0"))
      .join("");
  }
  
  // ===================== PERMUTATIONS =====================
  
  function* permutations(arr, n = arr.length) {
    if (n <= 1) yield arr.slice();
    else {
      for (let i = 0; i < n; i++) {
        yield* permutations(arr, n - 1);
        const j = n % 2 ? 0 : i;
        [arr[n - 1], arr[j]] = [arr[j], arr[n - 1]];
      }
    }
  }
  
  // ===================== SOLVER =====================
  
  const encrypted = Buffer.from(ENCRYPTED_DATA, "base64");
  let tested = 0;
  
  for (const order of permutations([...HIT_VALUES])) {
    tested++;
    if (tested % 10000 == 0)
      console.log(tested);
    const key = computeKey(order);
    const decrypted = rc4(key, encrypted);
  
    let plain;
    try {
      plain = zlib.inflateSync(decrypted);
    } catch {
      try {
        plain = zlib.inflateRawSync(decrypted);
      } catch {
        continue;
      }
    }
  
    if (plain[0] !== 0x7b) continue; // must start with '{'
  
    try {
      const json = JSON.parse(plain.toString("utf8"));
      console.log("\n🎉 SUCCESS!");
      console.log("Key:", key);
      console.log("Order:", order.map(v => v.toString(16)));
      console.log("JSON:", json);
  
      if (json.flag) {
        console.log("\n🏁 FLAG:", json.flag);
      }
  
      process.exit(0);
    } catch {}
  }
  
  console.log("❌ No valid permutation found.");
  console.log("Tried:", tested);