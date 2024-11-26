#[starknet::contract]
pub mod decimal_math{
    use core::traits::Into;
    use core::clone::Clone;
    use core::serde::Serde;
    #[storage]
    struct Storage {}

    // @dev Returns 1 in the fixed point representation, with `decimals` decimals.
    pub fn unit(decimals: @u256) -> u256{
        let base: u256 = 10;
        return base**(decimals);
    }
    
    /// @dev Adds x and y, assuming they are both fixed point with 18 decimals.
    pub fn addd(x: u256, y: u256) -> u256{
        return x + y;
    }

    /// @dev Subtracts y from x, assuming they are both fixed point with 18 decimals.
    pub fn subd(x: u256, y: u256) -> u256{
        return x - y;
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with 18 digits.
    pub fn muld(x: u256, y: u256) -> u256{
        return muldin(x, y, 18);
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with `decimals` digits.
    fn muldin(x: u256, y: u256, decimals: u256) -> u256{
        return (x * y) / unit(@decimals);
    }

    /// @dev Divides x between y, assuming they are both fixed point with 18 digits.
    pub fn divd(x: u256, y: u256) -> u256{
        return divdin(x, y, 18);
    }

    /// @dev Divides x between y, assuming they are both fixed point with `decimals` digits.
    fn divdin(x: u256, y: u256, decimals: u256) -> u256{
        return (x * unit(@decimals)) / y;
    }
}